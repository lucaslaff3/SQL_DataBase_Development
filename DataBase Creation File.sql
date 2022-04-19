create database instacart;

create table orders
(order_id	varchar(15) NOT NULL,
 user_id 	varchar(15) NOT NULL,
eval__set 	varchar(15) NOT NULL,
order_number integer	NOT NULL,
order_dow 	varchar(8) NOT NULL,
order_hour_of_day int NOT NULL,
days_since_prior varchar(4),
	primary key (order_id));
    
create table products
(product_id varchar(15) NOT NULL,
product_name varchar(15) not null,
aisle_id int not null,
department_id varchar(15) not null,
primary key (product_id));
-- NEED TO SET THESE CONSTRAINTS AFTER I UPLOAD INFORMATION
-- foreign key (aisle_id) references aisles(aisle_id), DONE
-- foreign key (department_id) references departments(department_id));
    
alter table products
modify column product_name varchar(170) not null;
    
create table aisles
(aisle_id int not null,
aisle varchar(30) not null,
primary key (aisle_id));

create table departments
(department_id varchar(25) not null,
department varchar(15) not null,
primary key (department_id));


create table order_products_train
(order_id varchar(15) not null,
product_id varchar(15) not null, 
add_to_cart_order int not null,
reordered int not null);
-- need to set these constraints after info uploaded 
-- foreign key (order_id) references orders(order_id), DONE
-- foreign key (product_id) references products(product_id)); DONE

create table order_products_prior 
(order_id varchar(15) not null,
product_id varchar(15) not null,
add_to_cart_order varchar(15) not null,
reordered int not null);
 -- need to set these constraints after info uploaded 
-- foreign key (order_id) references orders(order_id), DONE
-- foreign key (product_id) references products(product_id)); DONE 

SET GLOBAL local_infile = 'ON';
SHOW VARIABLES LIKE "local_infile";
SHOW VARIABLES LIKE "secure_file_priv";




-- 	Loaded aisles
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/aisles.csv'
into table aisles
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


-- Loaded departments 
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/departments.csv'
into table departments
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


-- Loaded products
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
into table products
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


-- Loaded orders
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
into table orders
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- Loading products prior
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_products__prior.csv'
into table order_products_prior
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- Loading order products train FOREIGN KEY RESTRAINT 
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_products__train.csv'
into table order_products_train
character set utf8
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

-- ADDING CONSTRAINTS AFTER TABLES HAVE BEEN CREATED
alter table order_products_prior add
constraint product_id foreign key (product_id)
references products(product_id);

alter table order_products_prior 
add constraint product_id 
foreign key (order_id) references orders(order_id);

 alter table order_products_train 
 add constraint product_id
 foreign key (product_id) references products(product_id);

alter table order_products_train 
add constraint fk_3 
foreign key (order_id) references orders(order_id);

alter table products 
add constraint ak_1 
foreign key (aisle_id) references aisles(aisle_id);

 alter table products 
 add constraint ak_2 
 foreign key (department_id) references departments(department_id);
-- ADDING CONSTRAINTS AFTER TABLES HAVE BEEN CREATED

create table order_products 
select * from order_products_prior
union
select * from order_products_train;

drop table order_products;







