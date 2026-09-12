
create table raw_transactions as 
select * from read_csv_auto('data/transactions.csv');