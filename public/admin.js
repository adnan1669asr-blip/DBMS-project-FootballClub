async function fetchAllData() {
    const res = await fetch('/api/admin/all-data');
    const data = await res.json();
    const container = document.getElementById('tables');
    container.innerHTML = '';

    for (const [table, rows] of Object.entries(data)) {
        const tableDiv = document.createElement('div');
        tableDiv.className = 'table-container';
        tableDiv.innerHTML = `<h2>${table}</h2>`;

        const insertForm = document.createElement('form');
        insertForm.onsubmit = async e => {
            e.preventDefault();
            const row = {};
            Array.from(insertForm.elements).forEach(el => {
                if (el.name && el.value) row[el.name] = el.value;
            });
            await fetch('/api/admin/insert', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ table, row })
            });
            fetchAllData();
        };

        if (Array.isArray(rows) && rows.length > 0) {
            const headers = Object.keys(rows[0]);
            const htmlTable = document.createElement('table');
            htmlTable.innerHTML = `<tr>${headers.map(h => `<th>${h}</th>`).join('')}<th>Delete</th></tr>` +
                rows.map(row => `<tr>${headers.map(h => `<td>${row[h]}</td>`).join('')}<td><button data-table="${table}" data-key="${headers[0]}" data-value="${row[headers[0]]}">Delete</button></td></tr>`).join('');
            tableDiv.appendChild(htmlTable);

            headers.forEach(h => {
                const input = document.createElement('input');
                input.name = h;
                input.placeholder = h;
                insertForm.appendChild(input);
            });

            const submitBtn = document.createElement('button');
            submitBtn.type = 'submit';
            submitBtn.textContent = 'Add';
            insertForm.appendChild(submitBtn);
        } else {
            tableDiv.innerHTML += '<p>No data</p>';
        }

        tableDiv.appendChild(insertForm);
        container.appendChild(tableDiv);
    }

    container.querySelectorAll('button[data-table]').forEach(btn => {
        btn.onclick = async function () {
            const table = btn.dataset.table;
            const key = btn.dataset.key;
            const value = btn.dataset.value;
            await fetch('/api/admin/delete', {
                method: 'DELETE',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ table, key, value })
            });
            fetchAllData();
        };
    });
}

fetchAllData();
