-- VIEW 1: ActiveLoansView

    -- Query 1: Detailed Overdue Loans Report with Reader and Book Information

    SELECT 
        R.ReaderID,
        R.FirstName,
        R.LastName,
        A.ID AS BookID,
        B.Title,
        A.LoanDate,
        A.DueDate,
        (CURRENT_DATE - A.DueDate) AS DaysOverdue
    FROM ActiveLoansView A
    JOIN Readers R ON A.ReaderID = R.ReaderID
    JOIN Book B ON A.ID = B.ID
    WHERE A.DueDate < CURRENT_DATE
    ORDER BY DaysOverdue DESC;

    -- This query identifies all overdue active loans and enriches the result by joining with the Readers and Book tables to retrieve the reader's 
    -- name and the book title. It also calculates the number of days each loan is overdue. 

        -- TIME: 00.490s


    -- Query 2: Active Loans Analysis by Reader Card Type with Average Loan Duration

    SELECT 
        RC.CardType,
        COUNT(A.ReaderID) AS TotalActiveLoans,
        AVG(A.DueDate - A.LoanDate) AS AvgLoanDuration
    FROM ActiveLoansView A
    JOIN ReaderCard RC ON A.ReaderID = RC.ReaderID
    GROUP BY RC.CardType
    ORDER BY TotalActiveLoans DESC;

    -- This query identifies all overdue active loans and enriches the result by joining with the Readers and Book tables 
    -- to retrieve the reader's name and the book title. It also calculates the number of days each loan is overdue. 

        -- TIME: 00.299s


-- VIEW 2: MostReadGenresView

    -- Query 1: Top Genre Profile per Reader with Average Book Page Count
    
    SELECT 
        M.ReaderID,
        M.FirstName,
        M.LastName,
        M.GenreName,
        M.ReadCount,
        AVG(B.Page_Count) AS AvgPageCount
    FROM MostReadGenresView M
    JOIN BooksOnLoan L ON M.ReaderID = L.ReaderID
    JOIN Type_of T ON L.BookID = T.ID
    JOIN Genre G ON T.Genre_ID = G.Genre_ID
    JOIN Book B ON B.ID = T.ID
    WHERE G.Name = M.GenreName
    GROUP BY M.ReaderID, M.FirstName, M.LastName, M.GenreName, M.ReadCount
    ORDER BY M.ReadCount DESC;

    -- This query enhances the MostReadGenresView by joining it with the BooksOnLoan, Type_of, Genre, and Book tables. 
    -- The goal is to calculate the average page count of the books a reader has loaned in their most-read genre. 

        -- TIME: 01.422s


    -- Query 2: Overall Genre Engagement Analysis with Correlated Loan Duration

    SELECT 
        M.GenreName,
        COUNT(*) AS ReaderCount,
        SUM(M.ReadCount) AS TotalReads,
        AVG(M.ReadCount) AS AvgReadsPerReader,
        (
        SELECT AVG(L.DueDate - L.LoanDate)
        FROM BooksOnLoan L
        JOIN Type_of T ON L.BookID = T.ID
        JOIN Genre G ON T.Genre_ID = G.Genre_ID
        WHERE G.Name = M.GenreName
        ) AS OverallAvgLoanDuration
    FROM MostReadGenresView M
    GROUP BY M.GenreName
    ORDER BY TotalReads DESC;

    -- This query aggregates the top genres from MostReadGenresView to provide an overall engagement analysis. 
    -- It calculates the total number of reads and the average number of reads per reader for each genre. 
    -- Additionally, a correlated subquery computes the average loan duration (in days) for books in each genre.

        -- TIME: 02.875s
