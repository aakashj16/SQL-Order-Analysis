-- creating database
create database if not exists orders;

-- selecting database
use orders;

-- creating tables
create table if not exists address
(
	address_id int auto_increment primary key,
    address_line_1 varchar(50) not null,
    address_line_2 varchar(50),
    city varchar(50) not null,
    state varchar(50) not null,
    pincode varchar(10) not null,
    country varchar(50) not null
);

create table if not exists online_customers
(
	customer_id int auto_increment primary key,
    customer_first_name varchar(50) not null,
    customer_last_name varchar(50) not null,
    customer_email_id varchar(100) unique not null,
    address_id int not null,
		foreign key (address_id) references address(address_id)
			on delete cascade
			on update cascade,
	customer_creation_date date default (current_date),
    customer_username varchar(25) not null,
    customer_gender enum("M", "F", "O") not null
);

create table if not exists shipper
(
	shipper_id int auto_increment primary key,
    shipper_name varchar(50) not null,
	shipper_email_id varchar(50) unique not null,
    shipper_pincode varchar(10) not null
);

create table if not exists order_header
(
	order_id int auto_increment primary key,
    customer_id int not null,
		foreign key (customer_id) references online_customers(customer_id)
			on delete cascade
            on update cascade,
	order_date date default (current_date),
    order_status enum("Cancelled", "Pending", "Shipped", "Delivered") not null,
    payment_mode enum("Bank Transfer", "COD", "Credit Card", "Debit Card") not null,
    shipper_id int not null,
		foreign key (shipper_id) references shipper(shipper_id)
			on delete cascade
            on update cascade
);

create table if not exists product_class
(
	product_class_code int auto_increment primary key,
    product_class_description varchar(50) not null
);

create table if not exists products
(
	product_id int auto_increment primary key,
    product_class_code int not null,
		foreign key (product_class_code) references product_class(product_class_code)
			on delete cascade
            on update cascade,
    product_price decimal(9, 2) not null,
		constraint check_product_price check (product_price > 0),
    product_quantity_available int not null,
		constraint check_product_quantity_available check (product_quantity_available >= 0),
    product_length int not null,
		constraint check_product_length check (product_length > 0),
    product_width int not null,
		constraint check_product_width check (product_width > 0),
    product_height int not null,
		constraint check_product_height check (product_height > 0),
    product_weight decimal(8, 2) not null,
		constraint check_product_weight check (product_weight > 0)
);

create table if not exists order_items
(
	order_id int not null,
		foreign key (order_id) references order_header(order_id)
			on delete cascade
            on update cascade,
	product_id int not null,
		foreign key (product_id) references products(product_id)
			on delete cascade
            on update cascade,
    product_quantity int not null
		constraint check_product_quantity check (product_quantity > 0)
);