-- إنشاء قاعدة البيانات (نفذها فقط مرة وحدة خارج السكريبت أو من PGAdmin)
-- CREATE DATABASE HandmadeStore;

-- جدول المستخدمين
CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL,
    Email TEXT UNIQUE NOT NULL,
    PasswordHash TEXT NOT NULL,
    Phone TEXT,
    UserType TEXT DEFAULT 'Customer' CHECK (UserType IN ('Customer', 'Seller', 'Admin')),
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول عناوين المستخدمين
CREATE TABLE UserAddresses (
    AddressID SERIAL PRIMARY KEY,
    UserID INT NOT NULL,
    AddressType TEXT DEFAULT 'Home' CHECK (AddressType IN ('Home', 'Work', 'Other')),
    Street TEXT NOT NULL,
    City TEXT NOT NULL,
    State TEXT,
    PostalCode TEXT,
    Country TEXT NOT NULL,
    IsDefault BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- جدول الفئات
CREATE TABLE Categories (
    CategoryID SERIAL PRIMARY KEY,
    CategoryName TEXT NOT NULL,
    CategoryDescription TEXT,
    ParentCategoryID INT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);

-- جدول المنتجات
CREATE TABLE Products (
    ProductID SERIAL PRIMARY KEY,
    SellerID INT NOT NULL,
    CategoryID INT NOT NULL,
    ProductName TEXT NOT NULL,
    ProductDescription TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    SKU TEXT UNIQUE,
    Weight DECIMAL(8, 3),
    Dimensions TEXT,
    MaterialsUsed TEXT,
    HandmadeTime TEXT,
    IsCustomizable BOOLEAN DEFAULT FALSE,
    CustomizationOptions TEXT,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SellerID) REFERENCES Users(UserID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- جدول صور المنتجات
CREATE TABLE ProductImages (
    ImageID SERIAL PRIMARY KEY,
    ProductID INT NOT NULL,
    ImageURL TEXT NOT NULL,
    ImageAlt TEXT,
    IsPrimary BOOLEAN DEFAULT FALSE,
    DisplayOrder INT DEFAULT 0,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);

-- جدول الطلبات
CREATE TABLE Orders (
    OrderID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderStatus TEXT DEFAULT 'Pending' CHECK (OrderStatus IN ('Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Refunded')),
    TotalAmount DECIMAL(10, 2) NOT NULL,
    ShippingCost DECIMAL(8, 2) DEFAULT 0.00,
    TaxAmount DECIMAL(8, 2) DEFAULT 0.00,
    DiscountAmount DECIMAL(8, 2) DEFAULT 0.00,
    PaymentMethod TEXT NOT NULL CHECK (PaymentMethod IN ('CashOnDelivery', 'CreditCard', 'BankTransfer', 'DigitalWallet')),
    PaymentStatus TEXT DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Paid', 'Failed', 'Refunded')),
    ShippingAddress TEXT NOT NULL,
    BillingAddress TEXT,
    Notes TEXT,
    EstimatedDeliveryDate DATE,
    ActualDeliveryDate DATE,
    TrackingNumber TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Users(UserID)
);

-- جدول تفاصيل الطلبات
CREATE TABLE OrderDetails (
    OrderDetailID SERIAL PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    SellerID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10, 2) NOT NULL,
    TotalPrice DECIMAL(10, 2) NOT NULL,
    CustomizationDetails TEXT,
    ProductSnapshot TEXT, -- JSON data
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SellerID) REFERENCES Users(UserID)
);

-- جدول سلة التسوق
CREATE TABLE ShoppingCart (
    CartID SERIAL PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    CustomizationDetails TEXT,
    AddedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    UNIQUE (UserID, ProductID)
);

-- جدول المراجعات والتقييمات
CREATE TABLE Reviews (
    ReviewID SERIAL PRIMARY KEY,
    ProductID INT NOT NULL,
    UserID INT NOT NULL,
    OrderID INT,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ReviewTitle TEXT,
    ReviewText TEXT,
    IsVerifiedPurchase BOOLEAN DEFAULT FALSE,
    IsApproved BOOLEAN DEFAULT TRUE,
    HelpfulCount INT DEFAULT 0,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- جدول قوائم الرغبات
CREATE TABLE Wishlists (
    WishlistID SERIAL PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    UNIQUE (UserID, ProductID)
);

-- جدول الإشعارات
CREATE TABLE Notifications (
    NotificationID SERIAL PRIMARY KEY,
    UserID INT NOT NULL,
    NotificationType TEXT NOT NULL,
    Title TEXT NOT NULL,
    Message TEXT NOT NULL,
    IsRead BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- الفهارس
CREATE INDEX IX_Products_Seller ON Products(SellerID);
CREATE INDEX IX_Products_Category ON Products(CategoryID);
CREATE INDEX IX_Products_Active ON Products(IsActive);
CREATE INDEX IX_Orders_Customer ON Orders(CustomerID);
CREATE INDEX IX_Orders_Status ON Orders(OrderStatus);
CREATE INDEX IX_Orders_Created ON Orders(CreatedAt);
CREATE INDEX IX_Reviews_Product ON Reviews(ProductID);
CREATE INDEX IX_Reviews_User ON Reviews(UserID);
CREATE INDEX IX_Cart_User ON ShoppingCart(UserID);

-- بيانات تجريبية للفئات
INSERT INTO Categories (CategoryName, CategoryDescription) VALUES
('الحرف اليدوية', 'منتجات مصنوعة يدوياً بمهارة حرفية عالية'),
('المجوهرات', 'مجوهرات وإكسسوارات مصنوعة يدوياً'),
('الديكور المنزلي', 'قطع زينة وديكور للمنزل'),
('الملابس والأقمشة', 'ملابس وأقمشة مطرزة ومصممة يدوياً'),
('الفخار والسيراميك', 'منتجات فخارية وخزفية'),
('الأعمال الخشبية', 'منتجات خشبية مصنوعة يدوياً'),
('اللوحات والرسم', 'لوحات فنية ورسومات'),
('المنسوجات', 'سجاد وبسط ومنسوجات يدوية');

-- مستخدم إداري افتراضي
INSERT INTO Users (FirstName, LastName, Email, PasswordHash, UserType) VALUES
('المدير', 'العام', 'admin@handmadestore.com', '$2y$10$encrypted_password_here', 'Admin');
