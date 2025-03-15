#!/usr/bin/bash

DB_dir="DB"

# Check if the DB directory exists
if [ -d "$DB_dir" ]; then
    echo "There is a directory named '$DB_dir'."
else
    echo "There is no directory named '$DB_dir'."
    mkdir "$DB_dir"
    echo "Directory '$DB_dir' created."
fi

# Function to display the database menu
database_menu() {
    echo "Database Menu:"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Delete Database"
    echo "4. Connect to Database"
    echo "5. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1) create_database ;;
        2) list_database ;;
        3) delete_database ;;
        4) connect_database ;;
        5) confirm_exit ;;
        *) echo "Invalid choice. Please choose from the menu." ;;
    esac
}

# Function to create a database
create_database() {
    read -p "Enter the database name: " DB_name
    if [[ -d "$DB_dir/$DB_name" ]]; then
        echo "Database '$DB_name' already exists."
    else
        mkdir -p "$DB_dir/$DB_name"
        echo "Database '$DB_name' created successfully."
    fi
    database_menu
}

# Function to list databases
list_database() {
    echo "List of Databases:"
    if [[ -d "$DB_dir" ]]; then
        if [ -z "$(ls -A "$DB_dir")" ]; then
            echo "No databases found."
        else
            ls "$DB_dir"
        fi
    else
        echo "No databases found."
    fi
    database_menu
}

# Function to delete a database
delete_database() {
    read -p "Enter the database name to delete: " DB_name
    if [[ -d "$DB_dir/$DB_name" ]]; then
        rm -rf "$DB_dir/$DB_name"
        echo "Database '$DB_name' deleted successfully."
    else
        echo "Database '$DB_name' does not exist."
    fi
    database_menu
}

# Function to connect to a database
connect_database() {
    read -p "Enter the database name to connect: " DB_name
    if [[ -d "$DB_dir/$DB_name" ]]; then
        cd "$DB_dir/$DB_name"
        echo "Connected to database '$DB_name'."
        table_menu
    else
        echo "Database '$DB_name' does not exist."
        read -p "Do you want to create it? (yes/no): " create_choice
        case $create_choice in
            yes|YES|y|Y)
                mkdir -p "$DB_dir/$DB_name"
                echo "Database '$DB_name' created successfully."
                cd "$DB_dir/$DB_name"
                echo "Connected to database '$DB_name'."
                table_menu
                ;;
            no|NO|n|N)
                echo "Returning to the database menu."
                database_menu
                ;;
            *)
                echo "Invalid choice. Returning to the database menu."
                database_menu
                ;;
        esac
    fi
}

# Function to confirm exit
confirm_exit() {
    read -p "Are you sure you want to exit? (yes/no): " confirm
    case $confirm in
        yes|YES|y|Y)
            echo "Exiting the script. Goodbye!"
            exit 0
            ;;
        no|NO|n|N)
            echo "Returning to the database menu."
            database_menu
            ;;
        *)
            echo "Invalid input. Returning to the database menu."
            database_menu
            ;;
    esac
}

# Table Menu
table_menu() {
    echo "Table Menu:"
    echo "1. Create Table"
    echo "2. List Tables"
    echo "3. Drop Table"
    echo "4. Edit Table"
    echo "5. Select from Table"
    echo "6. Exit to Database Menu"
    read -p "Enter your choice: " choice

    case $choice in
        1) create_table ;;
        2) list_tables ;;
        3) drop_table ;;
        4) edit_table ;;
        5) select_from_table ;;
        6) exit_from_table_menu ;;
        *) echo "Invalid option. Please choose from the menu." ;;
    esac
}

# Function to create a table
create_table() {
    read -p "Enter the table name: " table_name
    if [[ -f "$table_name.csv" && -f "$table_name.meta" ]]; then
        echo "Table '$table_name' already exists."
    else
        read -p "Enter the number of fields: " num_fields
        read -p "Enter the field names (comma-separated, e.g., id,name,age): " field_names
        IFS=',' read -r -a fields <<< "$field_names"
        read -p "Enter the field types (comma-separated, e.g., int,str,str): " field_types
        read -p "Enter the primary key (leave blank to use the first field): " primary_key

        if [[ -z "$primary_key" ]]; then
            primary_key="${fields[0]}"
            echo "Using the first field '$primary_key' as the primary key."
        elif [[ ! " ${fields[@]} " =~ " ${primary_key} " ]]; then
            echo "Error: Primary key '$primary_key' does not exist in the field names."
            return
        fi

        # Save metadata
        echo "num_fields:$num_fields" > "$table_name.meta"
        echo "primary_key:$primary_key" >> "$table_name.meta"
        echo "field_names:$field_names" >> "$table_name.meta"
        echo "field_types:$field_types" >> "$table_name.meta"

        # Create CSV file with header
        echo "$field_names" > "$table_name.csv"
        echo "Table '$table_name' created successfully."
    fi
    table_menu
}

# Function to list tables
list_tables() {
    echo "List of Tables:"
    tables=$(ls *.csv 2>/dev/null)
    if [ -z "$tables" ]; then
        echo "No tables found."
    else
        for table in $tables; do
            echo "- ${table%.csv}"
        done
    fi
    table_menu
}

# Function to drop a table
drop_table() {
    read -p "Enter the table name to drop: " table_name
    if [[ -f "$table_name.csv" && -f "$table_name.meta" ]]; then
        rm -f "$table_name.csv" "$table_name.meta"
        echo "Table '$table_name' dropped successfully."
    else
        echo "Table '$table_name' does not exist."
    fi
    table_menu
}

# Function to edit a table (submenu)
edit_table() {
    echo "Edit Table Menu:"
    options=("Insert into Table" "Update Row" "Delete from Table" "Exit")
    select opt in "${options[@]}"; do
        case $opt in
            "Insert into Table") insert_data ;;
            "Update Row") update_row ;;
            "Delete from Table") delete_from_table ;;
            "Exit") table_menu ;;
            *) echo "Invalid option. Please choose from the menu." ;;
        esac
    done
}

# Function to insert data into a table
insert_data() {
    read -p "Enter the table name to insert data into: " table_name
    if [[ -f "$table_name.csv" && -f "$table_name.meta" ]]; then
        field_names=$(grep 'field_names:' "$table_name.meta" | cut -d':' -f2)
        new_row=""
        IFS=',' read -r -a fields <<< "$field_names"
        for field in "${fields[@]}"; do
            read -p "Enter value for '$field': " value
            new_row="${new_row}${value},"
        done
        new_row=${new_row%,}  # Remove the trailing comma
        echo "$new_row" >> "$table_name.csv"
        echo "Data inserted successfully into '$table_name'."
    else
        echo "Table '$table_name' does not exist."
    fi
    table_menu
}

# Function to update a row in a table
update_row() {
    read -p "Enter the table name to update a row in: " table_name
    if [[ -f "$table_name.csv" && -f "$table_name.meta" ]]; then
        primary_key=$(grep 'primary_key:' "$table_name.meta" | cut -d':' -f2)
        field_names=$(grep 'field_names:' "$table_name.meta" | cut -d':' -f2)
        IFS=',' read -r -a fields <<< "$field_names"
        read -p "Enter the primary key value of the row to update: " pk_value
        row=$(grep "^$pk_value," "$table_name.csv")

        if [[ -z "$row" ]]; then
            echo "No row found with primary key '$pk_value'."
        else
            IFS=',' read -r -a row_data <<< "$row"
            updated_row=()
            for ((i = 0; i < ${#fields[@]}; i++)); do
                field="${fields[i]}"
                current_value="${row_data[i]}"
                read -p "Enter new value for '$field' (current: $current_value): " new_value
                updated_row+=("$new_value")
            done
            updated_row_str=$(IFS=,; echo "${updated_row[*]}")
            sed -i "/^$pk_value,/c\\$updated_row_str" "$table_name.csv"
            echo "Row with primary key '$pk_value' updated successfully."
        fi
    else
        echo "Table '$table_name' does not exist."
    fi
    table_menu
}

# Function to delete a row from a table
delete_from_table() {
    read -p "Enter the table name to delete a row from: " table_name
    if [[ -f "$table_name.csv" && -f "$table_name.meta" ]]; then
        primary_key=$(grep 'primary_key:' "$table_name.meta" | cut -d':' -f2)
        read -p "Enter the primary key value of the row to delete: " pk_value
        if grep -q "^$pk_value," "$table_name.csv"; then
            sed -i "/^$pk_value,/d" "$table_name.csv"
            echo "Row with primary key '$pk_value' deleted successfully."
        else
            echo "No row found with primary key '$pk_value'."
        fi
    else
        echo "Table '$table_name' does not exist."
    fi
    table_menu
}

# Function to select data from a table
select_from_table() {
    read -p "Enter the table name to select data from: " table_name
    if [[ -f "$table_name.csv" && -f "$table_name.meta" ]]; then
        echo "Data in '$table_name':"
        echo "-------------------------"
        column -t -s, "$table_name.csv"
        echo "-------------------------"
    else
        echo "Table '$table_name' does not exist."
    fi
    table_menu
}

# Function to exit to the database menu
exit_from_table_menu() {
    cd ../..
    echo "Returning to the database menu."
    database_menu
}

# Start the database menu
database_menu
