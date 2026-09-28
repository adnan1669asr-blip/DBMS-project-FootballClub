const USER_TABLES = [
  'OrderItems',
  'Orders',
  'Tickets',
  'Merchandise',
  'News',
  'UserFan',
  'footballmanagment_game'
];

document.addEventListener('DOMContentLoaded', () => {
  const buttonsDiv = document.getElementById('table-buttons');
  const tableContainer = document.getElementById('table-container');

  // Show buttons
  USER_TABLES.forEach(table => {
    const btn = document.createElement('button');
    btn.textContent = table;
    btn.addEventListener('click', () => loadTable(table));
    buttonsDiv.appendChild(btn);
  });

  // Logout button
  document.getElementById('logout').addEventListener('click', () => {
    localStorage.clear();
    window.location.href = 'login.html';
  });
});

async function loadTable(tableName) {
  const tableContainer = document.getElementById('table-container');
  tableContainer.innerHTML = 'Loading...';

  try {
    const res = await fetch(`http://localhost:5000/api/user/${tableName}`);
    const data = await res.json();

    if (data.error) {
      tableContainer.innerHTML = `<p>Error: ${data.error}</p>`;
      return;
    }

    if (!data.length) {
      tableContainer.innerHTML = `<p>No records found in ${tableName}.</p>`;
      return;
    }

    const table = document.createElement('table');
    const thead = document.createElement('thead');
    const tbody = document.createElement('tbody');

    // Table header
    const headerRow = document.createElement('tr');
    Object.keys(data[0]).forEach(key => {
      const th = document.createElement('th');
      th.textContent = key;
      headerRow.appendChild(th);
    });
    thead.appendChild(headerRow);

    // Table body
    data.forEach(row => {
      const tr = document.createElement('tr');
      Object.values(row).forEach(val => {
        const td = document.createElement('td');
        td.textContent = val;
        tr.appendChild(td);
      });
      tbody.appendChild(tr);
    });

    table.innerHTML = '';
    table.appendChild(thead);
    table.appendChild(tbody);
    tableContainer.innerHTML = '';
    tableContainer.appendChild(table);
  } catch (err) {
    tableContainer.innerHTML = `<p>Error fetching table: ${err.message}</p>`;
  }
}
