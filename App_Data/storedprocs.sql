
CREATE PROCEDURE usp_CreateAccount
	@userID int,
    @Username varchar(50),
    @Password varchar(50),
    
    @Gender varchar(10),
    @CNIC varchar(15),
    @DOB date,
    @PhoneNumber varchar(20),
    @Email varchar(50),
    @Expertise varchar(50) = NULL,
    @Qualifications varchar(500) = NULL,
    @userType varchar(10),
	@workaddress varchar (30),
	@bankaccount varchar(20)
AS
BEGIN
    

    IF @userType = 'C' or @userType='A'
    BEGIN
        INSERT INTO Users (UserID, username, userpass, CNIC, birthdate, PhoneNumber, emailaddress)
		
        VALUES (@UserID,@Username, @Password, @CNIC, @DOB, @PhoneNumber, @Email)
    END

    IF @userType = 'F'
    BEGIN
        INSERT INTO Users (UserID, username, userpass, CNIC, birthdate, PhoneNumber, emailaddress,expertise)
        VALUES (@userID,  @Username, @Password, @CNIC, @DOB, @PhoneNumber, @Email, @Expertise)
    END
	
END


go

--/////////////////////////////////////////////////////////////////////////////////////////////
---------------------------------------------LOGIN----------------------------------------------

CREATE PROCEDURE Login(

    @Username VARCHAR(50),
    @Password VARCHAR(50)
)
AS
BEGIN
    DECLARE @Role VARCHAR(20)
    
    
    SELECT @Role = 'C'
    FROM Users
    WHERE Username = @Username AND userpass = @Password
    
    IF @Role IS NULL
    BEGIN
        
        SELECT @Role = 'F'
        FROM Users
        WHERE Username = @Username AND userpass = @Password
    END
    
    IF @Role IS NULL
    BEGIN
        
        SELECT @Role = 'A'
        FROM Users
        WHERE Username = @Username AND userpass = @Password
    END
    
    
    IF @Role IS NOT NULL
        SELECT @Role
    ELSE
        PRINT 'Invalid credentials'
END




go



CREATE PROCEDURE ForgotPassword(
    @Username VARCHAR(50),
    @Email VARCHAR(50)
)
AS
BEGIN
    DECLARE @Password VARCHAR(50)
    
   
    SELECT @Password = userpass
    FROM users
    WHERE Username = @Username AND emailaddress = @Email
    
    IF @Password IS NULL
    BEGIN
        
        SELECT @Password = userpass
        FROM users
        WHERE Username = @Username AND emailaddress = @Email
    END
    
    
    IF @Password IS NOT NULL
    BEGIN
        DECLARE @Body VARCHAR(MAX)
        SET @Body = 'Your password is: ' + @Password
        EXEC msdb.dbo.sp_send_dbmail 
            @profile_name='YourMailProfile',
            @recipients=@Email,
            @subject='Forgot Password',
            @body=@Body
    END
    ELSE
        PRINT 'Invalid credentials'
END
go





CREATE PROCEDURE UpdateUserProfile(
    @UserID INT,
    @Username VARCHAR(50),
    @Password VARCHAR(50),
    @Email VARCHAR(50),
    @Phone VARCHAR(50),
    @Name VARCHAR(50),
	@usertype char,
    @DateOfBirth DATE
	)
AS
BEGIN
    
    IF @usertype='A'
    BEGIN
        
        UPDATE [Users]
        SET Username = @Username,
            userpass = @Password,
            emailaddress = @Email,
            phonenumber = @Phone,
            birthdate = @DateOfBirth
        WHERE UserID = @UserID
    END



    ELSE IF @usertype='C' or @usertype='F'
    BEGIN

        UPDATE Users
        SET Username = @Username,
            userpass = @Password,
            Emailaddress = @Email,
            Phonenumber = @Phone
        WHERE UserID = @UserID
        
  
        IF (@Username <> (SELECT username FROM Users WHERE UserID = @UserID)) OR (@DateOfBirth <> (SELECT birthdate FROM Users WHERE UserID = @UserID) or (@userID <> (SELECT userID FROM Users WHERE UserID = @UserID)))
        BEGIN
            RAISERROR('Clients and freelancers are not authorized to change their username, date of birth or userID without contacting an admin.', 16, 1)
        END
    END
    ELSE
    BEGIN
       
        RAISERROR('Invalid user ID.', 16, 1)
    END
END


go


CREATE PROCEDURE DepositMoneyToWallet
    @UserID INT,
    @Amount DECIMAL(10, 2)
AS
BEGIN
    DECLARE @BankBalance DECIMAL(10, 2)
    
   
    IF NOT EXISTS (SELECT 1 FROM moneytransfers WHERE srcuser = @UserID)
    BEGIN
        RAISERROR('User does not have a valid bank account.', 16, 1)
        RETURN
    END
    
    
    SELECT @BankBalance = amount
    FROM MoneyTransfers
    WHERE srcuser = @UserID
    
    
    UPDATE moneytransfers
    SET amount = amount - @Amount
    WHERE srcuser = @UserID
    
    
    UPDATE MoneyTransfers
    SET amount = amount + @Amount,
       transfertime = GETDATE()
    WHERE dstuser = @UserID
    
    
    IF @BankBalance - @Amount != (SELECT amount FROM MoneyTransfers WHERE dstuser = @UserID)
    BEGIN
        RAISERROR('Error occurred while depositing money to wallet.', 16, 1)
        RETURN
    END
END
go


CREATE PROCEDURE WithdrawMoneyFromWallet
    @UserID INT,
    @Amount DECIMAL(10, 2),
    @BankAccountNumber VARCHAR(50)
AS
BEGIN
    DECLARE @WalletBalance DECIMAL(10, 2)
    
    
    IF NOT EXISTS (SELECT 1 FROM MoneyTransfers WHERE srcuser = @UserID AND bankaccount = @BankAccountNumber)
    BEGIN
        RAISERROR('User does not have a valid bank account.', 16, 1)
        RETURN
    END
    
   
    IF (SELECT amount FROM MoneyTransfers WHERE srcuser = @UserID) < @Amount
    BEGIN
        RAISERROR('Wallet balance is insufficient.', 16, 1)
        RETURN
    END
    
   
    SELECT @WalletBalance = amount
    FROM MoneyTransfers
    WHERE srcuser = @UserID
    
   
    UPDATE MoneyTransfers
    SET amount = amount - @Amount,
        transfertime = GETDATE()
    WHERE srcuser = @UserID
    
  
    UPDATE MoneyTransfers
    SET amount = amount + @Amount
    WHERE srcuser = @UserID AND bankaccount = @BankAccountNumber
    
  
    IF @WalletBalance - @Amount != (SELECT amount FROM MoneyTransfers WHERE srcuser = @UserID)
    BEGIN
        RAISERROR('Error occurred while withdrawing money from wallet.', 16, 1)
        RETURN
    END
END

go


CREATE PROCEDURE PostJob
    @clientID INT,
    @jobtitle VARCHAR(32),
    @jobtype VARCHAR(32),
    @jobvalue MONEY,
    @jobdetail TEXT,
    @duedate DATE
AS
BEGIN
    

    
    DECLARE @walletBalance MONEY;
    SELECT @walletBalance = amount FROM moneytransfers WHERE srcuser = @clientID;
    IF @jobvalue > @walletBalance
    BEGIN
        RAISERROR ('Insufficient balance in wallet. Please deposit sufficient funds to post the job.', 16, 1);
        RETURN;
    END

   

    DECLARE @commission MONEY;
    SET @commission = @jobvalue * 0.1;
    UPDATE MoneyTransfers SET amount = amount - @jobvalue - @commission WHERE srcuser = @clientID;

    
    INSERT INTO Jobs (clientID, jobtitle, jobtype, jobvalue, jobdetail, postdate, duedate, jobstatus)
    VALUES (@clientID, @jobtitle, @jobtype, @jobvalue, @jobdetail, GETDATE(), @duedate, 'T');

    
END
go






CREATE PROCEDURE EditJob
    @jobID INT,
    @clientID INT,
    @jobtitle VARCHAR(32),
    @jobtype VARCHAR(32),
    @jobvalue MONEY,
    @jobdetail TEXT,
    @duedate DATE
AS
BEGIN
    
    IF EXISTS(SELECT 1 FROM Jobs WHERE jobID = @jobID AND clientID = @clientID AND jobstatus = 'T')
    BEGIN
        
        IF NOT EXISTS(SELECT 1 FROM Jobs WHERE jobID = @jobID AND jobstatus = 'N')
        BEGIN
            
            UPDATE Jobs
            SET jobtitle = @jobtitle,
                jobtype = @jobtype,
                jobvalue = @jobvalue,
                jobdetail = @jobdetail,
                duedate = @duedate
            WHERE jobID = @jobID AND clientID = @clientID AND jobstatus = 'T'
        END
        ELSE
        BEGIN
            
            RAISERROR('Cannot edit job as a freelancer has already applied for it', 16, 1)
        END
    END
    ELSE
    BEGIN
        
        RAISERROR('Invalid job or client', 16, 1)
    END
END

go




CREATE PROCEDURE RemoveJob
    @jobID int,
    @clientID int
AS
BEGIN
    SET NOCOUNT ON;

    
    IF EXISTS (
        SELECT 1
        FROM Jobs
        WHERE jobID = @jobID AND clientID = @clientID AND jobstatus IN ('T', 'N')
    )
    BEGIN
        
       -- UPDATE Walletmoney
        --SET balance = balance + j.jobvalue
        --FROM Jobs j
        --JOIN Wallet w ON j.clientID = w.userID
        --WHERE j.jobID = @jobID

        DELETE FROM Jobs
        WHERE jobID = @jobID AND clientID = @clientID

        SELECT 'Job removed successfully' AS Message
    END
    --ELSE
    BEGIN
        RAISERROR('Cannot remove job. It has already been assigned to a freelancer.', 16, 1)
    END
END
go




CREATE PROCEDURE ViewPostedJobs
	@clientId INT
AS
BEGIN
	SELECT jobID, jobtitle, jobtype, jobvalue, jobdetail, postdate, duedate, jobstatus
	FROM Jobs
	WHERE clientID = @clientId;
END

go

CREATE PROCEDURE SearchJobsByCategory
    @category varchar(32)
AS
BEGIN
    SELECT * FROM Jobs WHERE jobstatus = 'T' AND jobtype = @category
END
go


CREATE PROCEDURE ApplyForJob
    @freelancerID int,
    @jobID int
AS
BEGIN
    
    IF EXISTS (SELECT 1 FROM Proposals WHERE lancerID = @freelancerID AND jobID = @jobID)
    BEGIN
        RAISERROR ('Freelancer has already applied for this job', 16, 1);
        RETURN;
    END

    
    DECLARE @jobStatus char(1);
    SELECT @jobStatus = jobstatus FROM Jobs WHERE jobID = @jobID;
    IF @jobStatus <> 'T'
    BEGIN
        RAISERROR ('Job is not available for application', 16, 1);
        RETURN;
    END

   
    INSERT INTO Proposals(lancerID, jobID,applydate )
    VALUES (@freelancerID, @jobID, GETDATE());

   
    UPDATE Jobs SET jobstatus = 'O' WHERE jobID = @jobID;
END
go



CREATE PROCEDURE ViewApplicantsAndRatings
    @clientID int,
    @jobID int
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Jobs WHERE jobID = @jobID AND clientID = @clientID)
    BEGIN
        RAISERROR ('The specified job either does not exist or was not posted by the specified client', 16, 1);
        RETURN;
    END

   
    SELECT 
        u.username AS freelancer_username,
        u.rating AS freelancer_rating
    FROM 
        Proposals as a 
        INNER JOIN Users u ON a.lancerID = u.userID
    WHERE 
        a.jobID = @jobID;

END
go





CREATE PROCEDURE AllocateJob
    @jobID int,
    @freelancerID int
AS
BEGIN
    
    DECLARE @jobStatus char(1);
    SELECT @jobStatus = jobstatus FROM Jobs WHERE jobID = @jobID;
    IF @jobStatus <> 'T'
    BEGIN
        RAISERROR ('Job is not available for allocation', 16, 1);
        RETURN;
    END

    
    UPDATE Jobs SET lancerID = @freelancerID, jobstatus = 'O' WHERE jobID = @jobID;

    
    DECLARE @freelancerEmail varchar(50);
    SELECT @freelancerEmail = emailaddress FROM Users WHERE userID = @freelancerID;
    SELECT @freelancerEmail AS 'Freelancer Email';
END
go



CREATE PROCEDURE ViewAppliedJobs
    @freelancerID int
AS
BEGIN
    SELECT J.jobID, J.jobtitle, J.jobtype, J.jobvalue, J.jobdetail, J.postdate, J.duedate, J.jobstatus, 
           U.username AS client_username, U.emailaddress AS client_email
    FROM Jobs J
    INNER JOIN Proposals A ON J.jobID = A.jobID
    INNER JOIN Users U ON J.clientID = U.userID
    WHERE A.lancerID = @freelancerID
    ORDER BY J.postdate DESC;
END
go

----------/////////////////////////////////////////////////
-----there are some issues here--------------------------(there should be deliverydate as well but for now i am using duedate)

CREATE PROCEDURE UploadDeliverable
    @jobID int,
    @freelancerID int,
    @deliverable varbinary(max)
AS
BEGIN
    
    IF NOT EXISTS (SELECT 1 FROM Jobs WHERE jobID = @jobID AND lancerID = @freelancerID)
    BEGIN
        RAISERROR ('Job has not been allocated to this freelancer', 16, 1);
        RETURN;
    END

    UPDATE Jobs SET jobstatus = 'D' WHERE jobID = @jobID;

    
    INSERT INTO Jobs(jobID, lancerID, deliverable, duedate)
    VALUES (@jobID, @freelancerID, @deliverable, GETDATE());
END
go


CREATE PROCEDURE MarkJobDone
	@jobID INT,
	@clientID INT
AS
BEGIN
	
	IF NOT EXISTS (SELECT * FROM Jobs WHERE jobID = @jobID AND clientID = @clientID)
	BEGIN
		RAISERROR('Job does not exist or does not belong to the specified client.', 16, 1)
		RETURN
	END

	DECLARE @jobValue MONEY, @lancerID INT, @walletMoney MONEY
	SELECT @jobValue = jobValue, @lancerID = lancerID FROM Jobs WHERE jobID = @jobID

	
	IF NOT EXISTS (SELECT * FROM Jobs WHERE jobID = @jobID AND jobstatus = 'D')
	BEGIN
		RAISERROR('Job is not marked as done by the freelancer.', 16, 1)
		RETURN
	END

	BEGIN TRANSACTION

	
	UPDATE Users SET walletmoney = walletmoney + @jobValue WHERE userID = @lancerID
	UPDATE Users SET walletmoney = walletmoney - @jobValue WHERE userID = @clientID

	
	UPDATE Jobs SET jobstatus = 'D' WHERE jobID = @jobID

	
	COMMIT TRANSACTION
END
go


------------------incomplete (rating column's confusing me)-------------- 
CREATE PROCEDURE RateUser
    @raterID int,
    @ratedID int,
    @jobID int,
    @rating int,
    @feedback text
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Users WHERE userID = @raterID)
    BEGIN
        RAISERROR('Invalid rater ID', 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM Users WHERE userID = @ratedID)
    BEGIN
        RAISERROR('Invalid rated ID', 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM Jobs WHERE jobID = @jobID)
    BEGIN
        RAISERROR('Invalid job ID', 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM Jobs WHERE jobID = @jobID AND clientID = @raterID)
    BEGIN
        RAISERROR('Only clients can rate freelancers for this job', 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM Jobs WHERE jobID = @jobID AND lancerID = @raterID)
    BEGIN
        RAISERROR('Only freelancers can rate clients for this job', 16, 1)
        RETURN
    END

    IF @rating NOT BETWEEN 1 AND 5
    BEGIN
        RAISERROR('Rating should be between 1 and 5', 16, 1)
        RETURN
    END

    IF @raterID = @ratedID
    BEGIN
        RAISERROR('Cannot rate yourself', 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM Proposals WHERE jobID = @jobID AND lancerID = @ratedID AND approvalstatus = 'A')
    BEGIN
        RAISERROR('The freelancer must have an approved proposal for this job', 16, 1)
        RETURN
    END

    UPDATE Users SET rating = ((rating * jobsdone) + @rating) / (jobsdone + 1), jobsdone = jobsdone + 1 WHERE userID = @ratedID

    --INSERT INTO Feedback (raterID, ratedID, jobID, rating, feedback) VALUES (@raterID, @ratedID, @jobID, @rating, @feedback)

    RETURN
END
go


CREATE PROCEDURE SendRequest
	@UserID INT,        
	@RequestText TEXT   
AS
BEGIN
	
	INSERT INTO Requests (sentby, requestdate, details, requeststatus)
	VALUES (@UserID, GETDATE(), @RequestText, 'P')

	
END
go




CREATE PROCEDURE ViewRequests
AS
BEGIN
	SELECT r.requestID, u.username AS sentby, r.requestdate, r.details, r.requeststatus
	FROM Requests r
	INNER JOIN Users u ON r.sentby = u.userID
	WHERE r.requeststatus = 'P'

	UNION

	SELECT r.requestID, u.username AS sentby, r.requestdate, r.details, r.requeststatus
	FROM Requests r
	INNER JOIN Users u ON r.handledby = u.userID
	WHERE r.requeststatus <> 'P'
	ORDER BY requestdate DESC;
END
GO

CREATE PROCEDURE HandleRequest
	@requestID int,
	@handledby int,
	@requeststatus char(1),
	@donedate date
AS
BEGIN
	UPDATE Requests
	SET handledby = @handledby,
	requeststatus = @requeststatus,
	donedate = @donedate
	WHERE requestID = @requestID;
END
GO


create procedure DeleteUserAccount
	@userID int
as
	begin
		
		delete from Users where userID = @userID;

		
		delete from Proposals where lancerID = @userID;

		
		delete from Jobs where clientID = @userID;

		
		delete from MoneyTransfers where srcuser = @userID or dstuser = @userID;

		
		delete from Requests where sentby = @userID;

		
		select 'User account deleted successfully.' as Message;
	end;
go


--incomplete
CREATE PROCEDURE logout_user (IN user_id INT)
BEGIN
   UPDATE users SET is_logged_in = 0 WHERE id = user_id;
END