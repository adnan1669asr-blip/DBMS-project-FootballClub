# Football Club Management System

A small full-stack football club management demo built with Node.js, Express, MySQL, and plain HTML/CSS/JavaScript. It includes club records, admin and fan dashboards, account signup/login, and sample order payment and approval flows.

## Features

- Browse and manage teams, athletes, coaches, referees, venues, games, statistics, awards, sponsors, and injuries.
- Sign up and log in as a fan, or use the sample admin account.
- Browse sample tickets, merchandise, orders, news, and fan records.
- Try the demo payment and admin order confirmation workflow. No real payment is processed.
- View a live football news feed when an internet connection is available.

## Requirements

- Node.js 18 or newer
- MySQL Server 8.x
- MySQL Workbench (recommended for importing the database)

## Setup

1. Create the database and sample records by opening `club.sql` in MySQL Workbench and executing the script.
2. Check the MySQL connection settings in `db.js`. The defaults are `localhost:3306`, user `root`, password `1234`, and database `footballmanagment`. Update these values to match your local MySQL account before starting the app.
3. From the project folder, install the Node.js dependencies:

	```sh
	npm install
	```

4. Start the server:

	```sh
	node server.js
	```

5. Open [http://localhost:5000](http://localhost:5000). The root URL opens the login page.

On Windows PowerShell, if `npm install` is blocked by the PowerShell script execution policy, run `npm.cmd install` instead. This avoids changing the machine's execution policy.

## Sample Accounts

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@football.local` | `admin123` |
| Fan | `fan@football.local` | `user123` |

These accounts are inserted by `club.sql`. Signup-created account passwords are hashed; the seeded demo passwords are stored as plain text to keep local testing simple.

## Using the Dashboards

### Fan Dashboard

1. Sign in with the fan demo account, or create an account using the signup form.
2. Select a table from the sidebar to view its records. Available data includes orders, order items, tickets, merchandise, club news, fan profiles, and the match schedule.
3. To test demo payment, enter an existing order ID in the payment form. Order `1` starts as pending. A successful demo payment marks it paid; it does not charge money.
4. Use the athlete news section to load or refresh the external football news feed. The feed needs internet access.

### Admin Dashboard

1. Sign in with the admin demo account.
2. Select a table to view its rows. For non-empty tables, the dashboard provides a form to insert rows and controls to delete rows.
3. Review the paid-order queue. Sample order `2` is already paid and awaiting confirmation; confirm it from the queue. You can also pay order `1` from the fan dashboard, then refresh the queue.

## Database Reference

The schema is split into these groups:

| Group | Tables or view | Purpose |
| --- | --- | --- |
| Club entities | `Venue`, `Team`, `PositionDetails`, `Athlete`, `Coach`, `Referee`, `Game` | Core club, personnel, venue, and match records |
| Club records | `Statistics`, `Awards`, `Sponsor`, `Injury` | Match performance and supporting club records |
| Relationships | `ParticipatesIn`, `LocatedIn`, `HasSponsor`, `GivenBy`, `WinsAward`, `Referees` | Links between teams, games, venues, sponsors, awards, and people |
| App accounts | `users`, `UserFan` | Login accounts and fan profiles |
| Demo commerce | `Orders`, `OrderItems`, `Tickets`, `Merchandise` | Sample order, ticket, and merchandise records |
| Content | `News` | Sample club news records |
| Match schedule view | `footballmanagment_game` | Dashboard-friendly view of `Game` |

## API Overview

The Express server exposes these main routes:

| Method | Route | Description |
| --- | --- | --- |
| `POST` | `/api/signup` | Create a fan account |
| `POST` | `/api/login` | Verify an account and return its role |
| `GET` | `/api/admin/all-data` | Read all dashboard tables as an admin |
| `GET` | `/api/user/all-data` | Read the fan dashboard tables |
| `POST` | `/api/admin/insert` | Insert a row into an admin-selected table |
| `DELETE` | `/api/admin/delete` | Delete a row from an admin-selected table |
| `POST` | `/api/orders/:orderId/demo-pay` | Simulate payment for a pending order |
| `GET` | `/api/admin/pending-orders` | List paid orders awaiting approval |
| `POST` | `/api/admin/orders/:orderId/confirm` | Confirm a paid order |
| `GET` | `/api/athlete-news` | Fetch a cached external news feed |

## Troubleshooting

- **MySQL access denied:** Confirm MySQL is running and update the host, port, username, password, and database in `db.js`.
- **Unknown database or missing tables:** Execute `club.sql` in MySQL Workbench and check that the active schema is `footballmanagment`.
- **Tables are empty after import:** The SQL script inserts sample data. Check the Workbench output for errors and refresh the dashboard after a successful import.
- **Port 5000 is already in use:** Stop the other server using that port, then run `node server.js` again.
- **The root page still shows an old response:** Restart `node server.js` after changing server code, then reload `http://localhost:5000`.

## Database Contents

The SQL script creates and seeds the core club tables, plus `users`, `UserFan`, `Orders`, `OrderItems`, `Tickets`, `Merchandise`, and `News`. It also creates the `footballmanagment_game` view used by the dashboard.

**Warning:** `club.sql` drops and recreates its tables before inserting sample data. Running it again will erase existing rows in those tables. Back up any data you need before executing it.

## Project Layout

```text
club.sql             MySQL schema and sample data
server.js            Express server and API routes
db.js                MySQL connection configuration
public/login.html    Login and signup page
public/admin.html    Admin dashboard
public/user-dashboard.html
							Fan dashboard
public/style.css     Shared page styles
```

## Local Demo Security

This project is intended for local development and coursework demos. It uses development database credentials in `db.js`, includes a plain-text demo password in the SQL seed, and does not implement production-grade authorization for its admin APIs. Do not expose it to the public internet or reuse these credentials in a deployed application.
