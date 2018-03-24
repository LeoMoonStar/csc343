--Schema for rental car database

-- What constraints from the domain could not be enforced?
--
--
--
--What constraints that could have been enforced but were not? Why?
--
--
--
--

drop schema if exists carschema cascade;
create schema carschema;
set search_path to carschema;

create type Res_status as ENUM(
  'Ongoing', 'Completed', 'Cancelled'
);

Create Table Customer(
  id INT Primary Key,
  age INT not null
  check (age >= 18),
  email varchar(50) not null unique
);

create Table Model(
  id INT primary key,
  name varchar(50) Not Null Unique,
  v_type varchar(50) Not null,
  model_num INT,
  capacity INT
);

create Table Rentalstation(
  code INT primary key,
  name varchar(100),
  address varchar(100),
  area_code varchar(10),
  city varchar (50)
);

Create Table Car(
  id INT primary key,
  license_num varchar(20) unique,
  station_code INT References Rentalstation(code),
  model_id INT References Model(id)
);


Create Table Reservation(
  id INT primary key,
  From_date Timestamp NOT Null,
  To_date Timestamp NOT Null,
  car_id INT References Car(id) NOT Null,
  old_res_id INT default null,
  status res_status NOT NUll
);

create table Customer_res(
  email varchar References Customer(email),
  res_num INT References Reservation(id)
);
