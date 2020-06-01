-- CSD 331

-- Define database
DROP DATABASE IF EXISTS museum;
CREATE DATABASE IF NOT EXISTS museum ;
USE museum;

-- Define tables
CREATE TABLE Grant_Source (
    grant_src CHAR(30) PRIMARY KEY
);

CREATE TABLE Employee (
    emp_numb CHAR(3) PRIMARY KEY,
    first_name CHAR(15),
    last_name CHAR(15),
    emp_phone CHAR(12)
);

CREATE TABLE Grant_table (
    grant_numb CHAR(3) PRIMARY KEY,
    grant_src CHAR(30),
    total_amt NUMERIC(10, 2 ),
    principal_researcher CHAR(3),
    FOREIGN KEY (grant_src) REFERENCES Grant_Source (grant_src),
    FOREIGN KEY (principal_researcher) REFERENCES Employee (emp_numb)
);

CREATE TABLE Vendor (
    vendor_numb CHAR(3) PRIMARY KEY,
    vendor_name CHAR(40),
    vendor_street CHAR(50),
    vendor_city CHAR(20),
    vendor_state CHAR(2),
    vendor_zip CHAR(10),
    vendor_phone CHAR(12)
);

CREATE TABLE Purchase (
    po_numb CHAR(6) PRIMARY KEY,
    po_date DATE,
    grant_numb CHAR(3),
    vendor_numb CHAR(3),
    FOREIGN KEY (grant_numb) REFERENCES Grant_table (grant_numb),
    FOREIGN KEY (vendor_numb) REFERENCES Vendor (vendor_numb)
);

CREATE TABLE Line_item (
    po_numb CHAR(6),
    item_description CHAR(30),
    cost_each NUMERIC(8 , 2 ),
    quantity INT,
    PRIMARY KEY (po_numb, item_description),
    FOREIGN KEY (po_numb) REFERENCES Purchase (po_numb)
);

CREATE TABLE Dig (
    dig_numb CHAR(3) PRIMARY KEY,
    grant_numb CHAR(3),
    dig_description CHAR(30),
    location CHAR(30),
    FOREIGN KEY (grant_numb) REFERENCES Grant_table (grant_numb)
);

CREATE TABLE Dig_assignment (
    dig_numb CHAR(3),
    emp_numb CHAR(3),
    PRIMARY KEY (dig_numb , emp_numb),
    FOREIGN KEY (dig_numb) REFERENCES Dig (dig_numb),
    FOREIGN KEY (emp_numb) REFERENCES Employee (emp_numb)
);

-- Insert data - use column list and bulk load format
INSERT INTO Grant_source (grant_src)
values 
('NSF'), 
('Carnegie Foundation');

INSERT INTO Employee(emp_numb, first_name,last_name,emp_phone)
VALUES 
('001','Idaho','Smith','999-555-0001'),
('002','Leslie','Lewis','999-555-0002'),
('003','Indigo','Jones','999-555-0003'),
('004','Jackrabbit','Johnson','999-555-0004'),
('005','Big Cheese','Boss','999-555-0005'),
('006','Marian','Librarian','999-555-0006'),
('007','Stays In','Clerk','999-555-0007'),
('008','Loves To','Dig','999-555-0008'),
('009','Starving','GraduateStudent','999-555-0009'),
('010','Poor','GraduateStudent','999-555-0010'),
('011','He Knows','More','999-555-0011'),
('012','She Knows','More','999-555-0012');

INSERT INTO Grant_table(grant_numb, grant_src,total_amt,principal_researcher)
Values 
('001','NSF',450000,'001'),
('002','Carnegie Foundation',30000,'001'),
('003','NSF',150000,'002'),
('004','NSF',75500,'003'),
('005','Carnegie Foundation',32750,'004');

INSERT INTO Vendor(vendor_numb,vendor_name,vendor_street,
vendor_city,vendor_state,vendor_zip,vendor_phone)
values 
('001','Archaeology Supply Co.','85 Northland Highway','Newtown','MA','02111','999-555-0211'),
('002','Westview Camping, Inc.','10876 Outer Ring Road','Westview','CA','96123','998-555-6123'),
('003','Charter Airlines','25 Airport Way','Oldtown','GA','42601','997-555-2601'),
('004','Digger’s Paradise','567 Hammondview','Eastview','TN','73109','996-555-3109');

INSERT INTO Purchase (po_numb,po_date,grant_numb,vendor_numb)
VALUES 
('000001',20040315,'001','003'),
('000002',20040321,'001','002'),
('000003',20040321,'002','001'),
('000004',20040325,'004','001'),
('000005',20040325,'003','004'),
('000006',20040402,'005','004');

INSERT INTO Line_item (po_numb,item_description,cost_each,quantity)
VALUES 
('000001','First class tickets to Mexico',2500.10,6),
('000002','6-man tent',109.00,4),
('000002','Dining canopy',209.95,2),
('000002','Mosquito netting',35.50,24),
('000002','Camp stools',18.50,24),
('000002','Fully-equipped camping kitchen',1500.95,2),
('000003','Brush, size 0',4.95,15),
('000003','Brush, size 2',5.95,15),
('000003','G-pick',15.80,15),
('000003','Shovel, size 0',21.95,15),
('000003','Dry specimen case, size S',7.50,100),
('000003','Dry specimen case, size M',12.50,75),
('000003','Dry specimen case, size L',19.95,25),
('000004','Sleeping bag',110.95,10),
('000004','2-man tent',185.95,5),
('000004','G-pick',15.80,20),
('000004','Shovel, size 0',21.95,10),
('000004','Brush, size 0',4.95,10),
('000004','Brush, size 1',6.95,10),
('000005','Twine, 1000 meters',17.50,5),
('000005','Broom, corn',12.50,3),
('000005','Canvas tent, one room, 20 x 15',609.00,2),
('000005','Folding table',125.95,15),
('000006','Chemical toilet',85.95,5),
('000006','Latrine tent, 5-stall',329.95,1),
('000006','Tissue for chemical toilets',1.25,100);

INSERT INTO DIG (dig_numb,grant_numb,dig_description,location)
VALUES 
('001', '002','Excavating Eskimo ruins','Barrow, AK'),
('002','001','Excavating a new pyramid','Giza, Egypt'),
('003','003','Documenting cave paintings','Rural France'),
('004','005','Excavating mammoth skeleton','Hyde Park, NY');

INSERT INTO Dig_assignment (dig_numb,emp_numb) 
VALUES 
('001', '001'), ('001', '008'), ('001', '009'),
('001', '010'), ('002', '001'), ('002', '011'),
('002', '012'), ('003', '002'), ('004', '004'),
('004', '003'), ('004', '011'), ('004', '012');

-- Select tables
Select * from Dig;
Select * from Grant_Source;
Select * from Employee;
Select * from Dig_Assignment;
Select * from Grant_Table;
Select * from Line_Item;
Select * from Purchase;
Select * from Vendor;