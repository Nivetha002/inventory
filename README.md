# Inventory & POS Management System

A Flutter-based mobile application for managing sales, walk-in POS transactions, purchases, inventory, customers, and reports across multiple organizations and branches. The system works with a web-based administration platform where organizations, branches, users, roles, and master data can be managed.

## App Screenshots
<img width="1536" height="1024" alt="Chappathi Corner POS UI Showcase" src="https://github.com/user-attachments/assets/73d74f78-7124-4b54-b024-a82dcf106ae8" />

## Features

### Organization and Branch Management

Organization, branch, user, and role management are available through the web-based administration platform.

- Create and manage organizations.
- Create multiple branches under an organization.
- Assign roles and users to branches.
- Configure user access based on role permissions.
- Customize the company name shown in the system.

### Mobile Application

Branch users can sign in to the mobile app with credentials provided by the organization.

- Secure user login.
- Product, category, customer, and user management.
- Sales, POS, purchase, and inventory workflows.
- Mobile configuration and report access.

### Product and Category Management

- Create and manage products and categories.
- Search and select products during sales and POS transactions.
- Manage product information for branch operations.

### Sales and POS

The application supports both registered-customer sales and walk-in POS transactions.

- Record regular sales for registered customers.
- Process POS transactions for walk-in customers.
- Generate bills for sales and POS transactions.
- Accept cash, credit, and UPI payments.
- Track credit balances for credit sales.
- Configure sales ID generation as continuous auto-increment or daily-reset manual numbering.

### Purchase and Inventory

- Record purchases from suppliers.
- Track stock received and sold.
- View current inventory levels.
- Identify low-stock products.

### Reports and Configuration

- Filter reports by date, month, item, and payment method.
- Review cash, credit, and UPI transactions.
- Download reports.
- Configure Bluetooth receipt printing.

## Technology Stack

| Area | Technology |
|---|---|
| Mobile framework | Flutter |
| Language | Dart |
| Database | PostgreSQL |
| Backend / API | Node js |
| State management | Provider|

## Application Workflow

```text
Super Admin
    ↓
Create Organization
    ↓
Create Branches
    ↓
Assign Roles and Users
    ↓
Branch User Signs In to Mobile App
    ↓
Manage Products, Customers, Sales, POS, Purchases, and Inventory
    ↓
View and Download Reports
```

## Sales and POS Workflow

```text
Select Products
      ↓
Add Items to Bill
      ↓
Choose Registered Customer or Walk-in
      ↓
Select Cash, Credit, or UPI
      ↓
Complete Sale
      ↓
Generate Bill and Update Inventory
      ↓
Update Customer Credit Balance, When Applicable
```

## Reports

Reports support filtering by:

- Date and month.
- Product or item.
- Payment method: cash, credit, or UPI.

Users can download reports from the mobile application.

## Bluetooth Printing

Configure a supported Bluetooth printer in the mobile application to print transaction bills.

## Project Setup

### Prerequisites

- Flutter SDK.
- Android Studio or Visual Studio Code.
- Access to the project backend and PostgreSQL database configuration.

### Install Dependencies

```bash
flutter pub get
```

### Configure the Application

Add the required backend/API settings using the project’s configuration method. Do not commit passwords, private keys, database credentials, or other secrets to the repository.

### Run the Application

```bash
flutter run
```

### Build Android APK

```bash
flutter build apk --release
```

## Project Status

This project supports multi-organization and multi-branch operations, with web-based administration and mobile workflows for sales, POS, purchases, inventory, configuration, and reporting.

## Author

**Nivetha**

Flutter Developer | Mobile Application Developer

- GitHub: [Nivetha002](https://github.com/Nivetha002)
- LinkedIn: [Nivetha](https://www.linkedin.com/in/nivetha002/)
