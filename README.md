# Bashscript-DBMS-file-based-managment
Bash script that simulate Database DBMS managment file based
# Bash Shell Script Database Management System (DBMS)

A command-line database management system (DBMS) built with Bash scripting, enabling users to create, manage, and interact with databases and tables stored on the hard disk. Designed for simplicity and efficiency, it supports basic CRUD operations and data validation.

---

## Features

### **Main Menu**
- **Create Database**: Create a new database directory.
- **List Databases**: Display all existing databases.
- **Connect to Database**: Navigate to a specific database to manage its tables.
- **Drop Database**: Delete an existing database.

### **Table Menu** (after connecting to a database)
- **Create Table**: Define a table with metadata (columns, data types, primary key).
- **List Tables**: Show all tables in the current database.
- **Drop Table**: Delete a table and its metadata.
- **Insert into Table**: Add data rows with type validation.
- **Select From Table**: Display table data in a formatted ASCII table.
- **Delete From Table**: Remove rows by primary key.
- **Update Row**: Modify existing rows by primary key.

### **Hints Implemented**
- Stores databases as directories and tables as CSV files (metadata in `.meta` files).
- Validates user input for data types (integers/strings).
- Uses relative paths only (no absolute paths).
- First column is treated as the primary key for delete/update operations.
- Metadata includes table name, number of columns, column names, and data types.

### **Bonus Features**
- *SQL Support (Optional)*: Accept SQL-like commands (e.g., `SELECT * FROM table`).
- *GUI (Optional)*: A graphical interface alongside the CLI (e.g., using `zenity` or `dialog`).

---

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/bash-dbms.git
   cd bash-dbms
