using FinPlanner.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

namespace FinPlanner.Console
{
    public class View : IView
    {
        private const string _welcomeString = "Welcome to Personal Financial Planner!\n";
        private const string _optionsString =
            "Please, select one of the options below:\n" +
            "0: Exit the program.\n" +
            "1: Display the balance sheet.\n" +
            "2: Update a balance sheet entry.\n" +
            "3: Close the financial month.\n";            

        private const string _optionsNextString = "Please, select one of the options (0-3): ";

        // Command codes
        private const string _exitCode = "0";
        private const string _displayBalanceSheetCode = "1";
        private const string _updateBalanceSheetCode = "2";
        private const string _closeCurrentMonth = "3";

        // Column names
        private const string _amountColumn = "Amount";
        private const string _accountNameColumn = "Account Name";
        private const string _accountNumberColumn = "Account No";
        private const string _goalNoColumn = "#";
        private const string _goalNameColumn = "Goal";
        private const string _dueToColumn = "Due to";
        private const string _dateColumn = "Date";
        private const string _categoryColumn = "Category";
        private const string _monthlyColumn = "Monthly";
        private const string _annualColumn = "Annual";
        private const string _descriptionColumn = "Description";
        private const string _budgetColumn = "Budget";

        // Other constants
        private const int _topGoalsNumber = 10;
        private const string _enterAccountNo = "Enter the Account No: ";
        private const string _enterMonthlyBudget = "Enter the monthly budget: ";
        private const string _enterDate = "Enter the date: ";
        private const string _enterMonth = "Enter the month: ";
        private const string _enterAmount = "Enter the amount: ";
        private const string _enterDescription = "Enter the description: ";
        private const string _balanceSheetEntryUpdateOk = "Balance sheet entry has been updated sucessfully.\n";
        private const string _monthlyBudgetEntryUpdateOk = "Monthly budget entry has been updated sucessfully.\n";
        private const string _setGoalImportance = "Set the importance of each goal from 1 to 10 (1 = most important):\n";
        private const string _setGoalTerm = "Set the term of each goal from 1 to 3 (1 = 1 year, 2 = 1-5 years, 3 = 5-10 years):\n";
        private const string _newGoalsSetOK = "New goals have been set successfully.\n";
        private const string _journalEntryAddedOK = "Journal entry has been added sucessfully.\n";
        private const string _financialMonthClosedOK = "Financial month has been closed successfully.\n";
        private const string _noEntriesCurrentMonth = "Journal has no entries in the current month.\n";
        private const string _noFinancialGoalsSet = "You haven't set your financial goals yet. Set the goals first (4).\n";
        private const string _noCashflowEntries = "No cashflow entries found for the specified month.\n";
        private const string _noBalanceSheetEntries = "No balance sheet entries found for the specified month.\n";

        // IView interface
        public event EventHandler<DateTime> BalanceSheetRequested;
        public event EventHandler<AccountBalanceEntry> BalanceSheetUpdated;
        public event EventHandler MonthEndClosingRequested;

        public void Show()
        {
            // Get the welcome message
            string welcome = _welcomeString + _optionsString;

            // Show the welcome message to user
            System.Console.Write(welcome);

            // User action code
            string code = string.Empty;

            // Wait for the code from user
            while (code != _exitCode)
            {
                // Read the user input
                code = System.Console.ReadLine();

                try
                {
                    // Handle the code
                    switch (code)
                    {
                        case _displayBalanceSheetCode:
                            {
                                var date = EnterMonth();
                                BalanceSheetRequested(this, date);
                                break;
                            }
                        case _updateBalanceSheetCode:
                            {
                                UpdateBalanceSheet();
                                break;
                            }
                        case _closeCurrentMonth:
                            {
                                CloseMonthEnd();
                                break;
                            }
                    }
                }
                catch (Exception ex)
                {
                    // Display the exception text
                    System.Console.WriteLine(ex.Message);
                }

                // Line-break for better readability
                System.Console.WriteLine();

                // Display the options again
                System.Console.Write(_optionsNextString);
            }
        }

        private static DateTime EnterMonth()
        {
            var date = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            System.Console.Write(_enterMonth);
            System.Windows.Forms.SendKeys.SendWait(date.ToShortDateString());
            date = DateTime.Parse(System.Console.ReadLine());
            return date;
        }

        public void ShowBalanceSheet(List<AccountBalanceEntry> items)
        {
            if (items.Count == 0)
            {
                // Tell the user there are no entries
                System.Console.Write(_noBalanceSheetEntries);
                return;
            }

            // Calculate max width for the columns to pad them right
            int width0 = _accountNumberColumn.Length + 1;
            int width1 = items.Max(x => x.AccountName.Length + x.Level) + 1;

            // Define the format of the line
            string format = "{0}{1}{2}\n";

            // Show the table header
            System.Console.Write(string.Format(format,
                _accountNumberColumn.PadRight(width0),
                _accountNameColumn.PadRight(width1),
                _amountColumn));

            foreach (AccountBalanceEntry item in items)
            {
                // Format the string
                string output = string.Format(format,
                    item.AccountNo.PadRight(width0),
                    (new string('-', item.Level) + item.AccountName).PadRight(width1),
                    item.Amount);

                // Display the balance sheet line
                System.Console.Write(output);
            }
        }

        private void UpdateBalanceSheet()
        {
            string accountNo = string.Empty;
            double amount = 0;

            // Ask user for Account No
            System.Console.Write(_enterAccountNo);
            accountNo = System.Console.ReadLine();

            // Ask user for Amount
            System.Console.Write(_enterAmount);
            string separator = Thread.CurrentThread.CurrentCulture.NumberFormat.NumberDecimalSeparator;
            System.Windows.Forms.SendKeys.SendWait("0" + separator + "0");
            amount = Double.Parse(System.Console.ReadLine());

            BalanceSheetUpdated(this,
                new AccountBalanceEntry()
                {
                    AccountNo = accountNo,
                    Amount = amount
                });

            // Give the user the success feedback
            System.Console.Write(_balanceSheetEntryUpdateOk);
        }

        private void CloseMonthEnd()
        {
            MonthEndClosingRequested(this, new EventArgs());

            // Give the user the success feedback
            System.Console.Write(_financialMonthClosedOK);
        }
    }
}
