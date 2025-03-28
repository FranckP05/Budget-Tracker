-- Create USER table
CREATE TABLE USER (
    UserID INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    pwd TEXT NOT NULL
);

-- Create WALLETS table
CREATE TABLE WALLETS (
    walletID INTEGER PRIMARY KEY AUTOINCREMENT,
    name_wallets TEXT NOT NULL,
    total REAL NOT NULL,
    limit REAL NOT NULL,
    color TEXT NOT NULL,
    UserID INTEGER NOT NULL,
    FOREIGN KEY (UserID) REFERENCES USER(UserID) ON DELETE CASCADE
);

-- Create CATEGORY table
CREATE TABLE CATEGORY (
    categoryID INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    color TEXT NOT NULL
);

-- Create EXPENSE table
CREATE TABLE EXPENSE (
    expenseID INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    amount REAL NOT NULL,
    date DATETIME NOT NULL,
    walletID INTEGER NOT NULL,
    categoryID INTEGER NOT NULL,
    FOREIGN KEY (walletID) REFERENCES WALLETS(walletID) ON DELETE CASCADE,
    FOREIGN KEY (categoryID) REFERENCES CATEGORY(categoryID) ON DELETE CASCADE
);
