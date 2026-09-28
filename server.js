const express = require('express');
const db = require('./db');
const bcrypt = require('bcrypt');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(express.json());
app.use(cors());

const PORT = 5000;
const ATHLETE_NEWS_URL = 'https://site.api.espn.com/apis/site/v2/sports/soccer/eng.1/news?limit=6';
let athleteNewsCache = { articles: [], fetchedAt: 0 };

// Add the fields needed by the demo payment and approval workflow if they do
// not exist yet. Existing orders remain pending until a demo payment is made.
function ensureOrderWorkflowSchema() {
    const columns = [
        ['payment_status', "VARCHAR(20) NOT NULL DEFAULT 'pending'"],
        ['order_status', "VARCHAR(20) NOT NULL DEFAULT 'pending'"],
        ['paid_at', 'DATETIME NULL'],
        ['confirmed_at', 'DATETIME NULL']
    ];

    columns.forEach(([name, definition]) => {
        db.query(
            `SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Orders' AND COLUMN_NAME = ?`,
            [name],
            (err, rows) => {
                if (err || rows.length) return;
                db.query(`ALTER TABLE Orders ADD COLUMN ${name} ${definition}`, alterErr => {
                    if (alterErr) console.error(`Could not add Orders.${name}:`, alterErr.message);
                });
            }
        );
    });
}

ensureOrderWorkflowSchema();

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'login.html'));
});

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// ------------------- Login -------------------
app.post('/api/login', (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ message: 'Email & password required' });

    db.query('SELECT * FROM users WHERE email = ?', [email], async (err, results) => {
        if (err) return res.status(500).json({ message: 'Database error' });
        if (results.length === 0) return res.status(401).json({ message: 'Invalid credentials' });

        const user = results[0];
        const match = user.password.startsWith('$2')
            ? await bcrypt.compare(password, user.password)
            : password === user.password;
        if (!match) return res.status(401).json({ message: 'Invalid credentials' });

        res.json({ 
            message: 'Login successful', 
            role: user.role, 
            name: user.name 
        });
    });
});

app.post('/api/signup', async (req, res) => {
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
        return res.status(400).json({ message: 'Name, email & password required' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        db.query(
            'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
            [name, email, hashedPassword, 'user'],
            (err) => {
                if (err) {
                    const message = err.code === 'ER_DUP_ENTRY'
                        ? 'Email already exists'
                        : 'Database error';
                    return res.status(500).json({ message });
                }
                res.status(201).json({ message: 'Signup successful. Please login.' });
            }
        );
    } catch (err) {
        res.status(500).json({ message: 'Signup failed' });
    }
});

// ------------------- Tables -------------------
const ADMIN_TABLES = [
    'users', 'Venue', 'Team', 'PositionDetails', 'Athlete', 'Coach', 'Referee', 'Game',
    'Statistics', 'Awards', 'Sponsor', 'Injury', 'ParticipatesIn', 'LocatedIn', 'HasSponsor',
    'GivenBy', 'WinsAward', 'Referees'
];

const USER_TABLES = [
    'OrderItems', 'Orders', 'Tickets', 'Merchandise', 'News', 'UserFan', 'footballmanagment_game'
];

// Admin fetch all tables (Admin sees everything)
app.get('/api/admin/all-data', (req, res) => {
    let results = {};
    let completed = 0;
    const tables = [...ADMIN_TABLES, ...USER_TABLES];

    tables.forEach(table => {
        db.query(`SELECT * FROM ${table}`, (err, rows) => {
            results[table] = err ? { error: err.message } : rows;
            completed++;
            if (completed === tables.length) res.json(results);
        });
    });
});

// User fetch only user tables (hide passwords in UserFan)
app.get('/api/user/all-data', (req, res) => {
    let results = {};
    let completed = 0;

    USER_TABLES.forEach(table => {
        db.query(`SELECT * FROM ${table}`, (err, rows) => {
            if (!err && table === 'UserFan') {
                // Remove password column for users
                rows = rows.map(row => {
                    const { password, ...rest } = row;
                    return rest;
                });
            }
            results[table] = err ? { error: err.message } : rows;
            completed++;
            if (completed === USER_TABLES.length) res.json(results);
        });
    });
});

// Free public football-news feed. The short cache keeps the dashboard quick
// and avoids making a remote request every time a user opens the page.
app.get('/api/athlete-news', async (req, res) => {
    const cacheIsFresh = Date.now() - athleteNewsCache.fetchedAt < 10 * 60 * 1000;
    if (cacheIsFresh) return res.json(athleteNewsCache.articles);

    try {
        const response = await fetch(ATHLETE_NEWS_URL, {
            signal: AbortSignal.timeout(8000),
            headers: { 'User-Agent': 'Football-Team-Management-Demo/1.0' }
        });
        if (!response.ok) throw new Error(`News provider responded with ${response.status}`);

        const data = await response.json();
        const articles = (data.articles || []).map(article => ({
            title: article.headline || article.title || 'Football update',
            summary: article.description || 'Read the latest football news.',
            url: article.links?.web?.href || article.link?.href || '',
            image: article.images?.[0]?.url || '',
            publishedAt: article.published || ''
        })).filter(article => article.url);

        athleteNewsCache = { articles, fetchedAt: Date.now() };
        res.json(articles);
    } catch (err) {
        console.error('Could not load athlete news:', err.message);
        res.status(502).json({ message: 'Live athlete news is temporarily unavailable.' });
    }
});

// ------------------- Demo payments and order approval -------------------
// This deliberately simulates a payment provider. A real provider should call
// a verified webhook instead of exposing the demo payment endpoint.
app.post('/api/orders/:orderId/demo-pay', (req, res) => {
    const orderId = Number(req.params.orderId);
    if (!Number.isInteger(orderId) || orderId < 1) {
        return res.status(400).json({ message: 'A valid order ID is required.' });
    }

    db.query(
        `UPDATE Orders
         SET payment_status = 'paid', paid_at = NOW()
         WHERE order_id = ? AND payment_status = 'pending'`,
        [orderId],
        (err, result) => {
            if (err) return res.status(500).json({ message: err.message });
            if (!result.affectedRows) {
                return res.status(409).json({ message: 'Order was not found or has already been paid.' });
            }
            res.json({ message: 'Demo payment complete. The admin has been notified.' });
        }
    );
});

app.get('/api/admin/pending-orders', (req, res) => {
    db.query(
        `SELECT o.order_id, o.user_id, o.order_date, o.total_amount, o.paid_at,
                COUNT(oi.order_item_id) AS item_count
         FROM Orders o
         LEFT JOIN OrderItems oi ON oi.order_id = o.order_id
         WHERE o.payment_status = 'paid' AND o.order_status = 'pending'
         GROUP BY o.order_id, o.user_id, o.order_date, o.total_amount, o.paid_at
         ORDER BY o.paid_at DESC`,
        (err, rows) => {
            if (err) return res.status(500).json({ message: err.message });
            res.json(rows);
        }
    );
});

app.post('/api/admin/orders/:orderId/confirm', (req, res) => {
    const orderId = Number(req.params.orderId);
    if (!Number.isInteger(orderId) || orderId < 1) {
        return res.status(400).json({ message: 'A valid order ID is required.' });
    }

    db.query(
        `UPDATE Orders
         SET order_status = 'confirmed', confirmed_at = NOW()
         WHERE order_id = ? AND payment_status = 'paid' AND order_status = 'pending'`,
        [orderId],
        (err, result) => {
            if (err) return res.status(500).json({ message: err.message });
            if (!result.affectedRows) {
                return res.status(409).json({ message: 'This order is not awaiting confirmation.' });
            }
            res.json({ message: 'Order confirmed successfully.' });
        }
    );
});

// Admin insert row
app.post('/api/admin/insert', (req, res) => {
    const { table, row } = req.body;
    const keys = Object.keys(row).join(', ');
    const values = Object.values(row).map(v => `'${v}'`).join(', ');
    db.query(`INSERT INTO ${table} (${keys}) VALUES (${values})`, (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

// Admin delete row (using primary key)
app.delete('/api/admin/delete', (req, res) => {
    const { table, key, value } = req.body;
    db.query(`DELETE FROM ${table} WHERE ${key} = '${value}'`, (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true });
    });
});

// Start server
app.listen(PORT, () => console.log(`🚀 Server running at http://localhost:${PORT}`));
