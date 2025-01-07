Pisaz - Build Your PC

Welcome to the Pisaz project, a comprehensive online system designed to simplify purchasing computer components and building custom PCs. This repository is part of a database design project to modernize the Pisaz platform, which previously relied on paper-based records.
Project Overview

Pisaz is an online platform specializing in selling computer parts. With an increasing user base, managing inventory, orders, and user interactions has become challenging. This project involves designing and implementing a robust database system to handle:

    Component inventory and compatibility checks.
    User management, including guest, registered, and premium users.
    Digital wallets, discount codes, and transactions.
    Advanced services like compatibility checks and purchase tracking.

Features
1. Component Management

    Supports various types of computer components like CPUs, GPUs, motherboards, etc.
    Tracks detailed attributes for each part, such as brand, specifications, and compatibility requirements.

2. User Types

    Guests: Can browse products but cannot make purchases.
    Registered Users: Can create accounts, view order history, and use digital wallets.
    Premium Users: Enjoy additional benefits like free delivery, personal discounts, and enhanced shopping features.

3. Digital Wallet and Discounts

    Allows users to store funds for quick payments.
    Supports public and personal discount codes for cost reduction.

4. Purchase Process

    From browsing to checkout, the system ensures seamless order handling.
    Integration with third-party logistics for delivery management.

5. Compatibility Checker

    Ensures selected components are compatible for building a custom PC.
    Provides recommendations to users for hassle-free purchases.

6. Logging System

    Records critical operations like account creation, order placement, and more for better traceability.

Technical Details
Database Design

This project uses an Enhanced Entity-Relationship (EER) model to design a scalable and efficient database. Key elements include:

    Entities: Products, Users, Transactions, Discounts.
    Relationships: User-Product interactions, Wallet transactions, Discount applications.
    Specialization: Differentiates between various user types and product categories.

Compatibility Rules

The system enforces specific compatibility rules, such as:

    Socket and chipset compatibility between CPUs and motherboards.
    Power requirements and physical dimensions for housing components.

Getting Started
Prerequisites

    Database Management System (DBMS): Ensure a compatible DBMS is installed (PostgreSQL).
    Development Environment: Django for backend development and React(if possible) for frontend developement.

Installation

    Clone the repository:

    git clone https://github.com/acontius/pisaz.git

    Set up the database using provided schema files.
    Configure the environment variables for DB credentials.
    Run the application.

Usage

    Browse the inventory and check compatibility using the Compatibility Checker.
    Create an account to unlock full features.
    Use the Digital Wallet and apply discount codes for purchases.
    Place an order and track it until delivery.

Contributing

We welcome contributions to improve Pisaz. To contribute:

    Fork the repository.
    Create a new branch for your feature or bug fix.
    Submit a pull request.

License

This project is licensed under the BASU License.
Acknowledgments

Special thanks to the course instructor, Dr. Morteza Yusef Sanaati, and teaching assistants for their guidance.
