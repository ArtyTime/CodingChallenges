-- TASK:

declare @clients table (id int, name varchar(20))
declare @invoices table (id int, summa numeric(18,2), clientId int)
declare @payments table (clientId int, payment numeric(18,2))

insert @clients (id, name)
values 
	(1, '1sr'), 
	(2, '2nd'), 
	(3, '3rd'),
	(4, '4th');
	
insert @invoices (id, summa, clientId)
values 
	(1, 10, 1), 
	(2, 15, 1), 
	(3, 20, 1), 
	(4, 25, 1), 
	(5, 12, 2), 
	(6, 14, 2), 
	(7, 200, 2), 
	(8, 100, 3), 
	(9, 200, 3);

insert @payments (clientId, payment)
values 
	(1, 30), 
	(2, 500), 
	(3, 100), 
	(4, 20);


-- SOLUTION:

-- Define the resulting table
declare @paidInvoices table (id int, summa numeric(18,2), clientId int)

-- Define property for calculation of sum of client's invoices
declare @ClientIvoicesSum numeric(18,2)

declare @previousClientID as int

-- Define cursor for iterating through invoices with the client's payments
declare Invoice_Cursor cursor for  
select i.*, p.payment
from @invoices as i
join @payments as p on i.clientId = p.clientId;

-- Define properties for our cursor
declare @InvoiceId as int
declare @InvoiceSumma as numeric(18,2)
declare @ClientID as int
declare @ClientPayment as numeric(18,2)

open Invoice_Cursor;  

-- Move to the first element of our cursor
fetch next from Invoice_Cursor into @InvoiceId, @InvoiceSumma, @ClientID, @ClientPayment;

set @ClientIvoicesSum = 0;
set @previousClientID = 0;

while (@ClientIvoicesSum <= @ClientPayment or @previousClientID = @ClientID) and @@FETCH_STATUS = 0	   
   begin
	  set @ClientIvoicesSum = @ClientIvoicesSum + @InvoiceSumma;

	  if @ClientIvoicesSum > @ClientPayment
	  begin		
		set @previousClientID = @ClientID;
		fetch next from Invoice_Cursor into @InvoiceId, @InvoiceSumma, @ClientID, @ClientPayment;

		-- If the new row in the cursor is for new client, then reset @ClientIvoicesSum
		if @previousClientID != @ClientID
		begin
			set @ClientIvoicesSum = 0;
			continue;
		end;
		
		-- Continue skipping the invoices for this customer when their sum is more than client's payment
		fetch next from Invoice_Cursor into @InvoiceId, @InvoiceSumma, @ClientID, @ClientPayment;		
		continue;
	  end;

	  -- Add fully paid invoice to the results table
	  insert into @paidInvoices
	  select * from @invoices 
	  where id = @InvoiceId;

	  set @previousClientID = @ClientID;

	  -- Move to the next invoice after processing the current one
      fetch next from Invoice_Cursor into @InvoiceId, @InvoiceSumma, @ClientID, @ClientPayment;

	  -- If the new row in the cursor is for new client, then reset @ClientIvoicesSum
	  if @previousClientID != @ClientID
	  begin
		set @ClientIvoicesSum = 0
	  end
   end;  

close Invoice_Cursor;  
deallocate Invoice_Cursor; 

select * from @paidInvoices;