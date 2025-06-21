# User Management Database Setup

hey read this first! 
if u wondering why my code is error , maybe u forget to make sure the SQL configuration is the same, don't ask questions, keep focusing!
This project includes a basic user table schema for managing user data, such as names, emails, and passwords.

## 📋 Table Structure

The following SQL script creates a database and a `users` table with the following structure:

| Field    | Type         | Null | Key | Default | Extra          |
|----------|--------------|------|-----|---------|----------------|
| id       | INT          | NO   | PRI | NULL    | auto_increment |
| nama     | VARCHAR(100) | YES  |     | NULL    |                |
| email    | VARCHAR(100) | YES  |     | NULL    |                |
| password | VARCHAR(255) | YES  |     | NULL    |                |

## 🛠️ How to Use

To use this structure in your own MySQL or MariaDB setup, follow these steps:

1. Open your MySQL client or admin tool (e.g., phpMyAdmin, MySQL Workbench).
2. Run the following SQL script:

```sql
-- Create the database

CREATE DATABASE IF NOT EXISTS nugas_db;

USE nugas_db;

-- build tabel users
CREATE TABLE IF NOT EXISTS users (
    id INT NOT NULL AUTO_INCREMENT,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

