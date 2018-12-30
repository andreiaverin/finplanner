using System;
using System.Linq;

namespace FinPlanner.Core
{
    public class Presenter
    {
        private const string _truncateGoalSetSQL = "TRUNCATE TABLE [dbo].[GoalSet]";
        private const string _exAccountNoNotFound = "Account No is not found!";
        private const string _noBalanceSheetAccountFound = "No balance sheet account found. Please, run the init script first.";
        private const string _noBalanceSheetRecordsFound = "No balance sheet records found. Please, close the previous financial month.";
        private const string _noCashflowAccountFound = "No cashflow account found. Please, run the init script first.";
        private const string _exMonthAlreadyClosed = "Financial month has been already closed.";
        private const int _balanceSheetDocumentID = 1;
        private const int _cashflowDocumentID = 2;

        private IView View { get; set; }

        public Presenter(IView view)
        {
            View = view;
            View.BalanceSheetRequested += View_BalanceSheetRequested;
            View.BalanceSheetUpdated += View_BalanceSheetUpdated;
            View.MonthEndClosingRequested += View_MonthEndClosingRequested;
        }

        private void View_BalanceSheetRequested(object sender, DateTime e)
        {
            using (var context = new FinPlannerEntities())
            {
                BalanceSheetCheck(context);

                // Re-calculate totals
                context.uspCalculateBalanceSheetTotals(e);

                // Project each row in the view into a BalanceSheetEntry 
                var sheet = context.vBalanceSheet
                    .Where(x => x.PostingDate.Value.Year == e.Year && x.PostingDate.Value.Month == e.Month)
                    .Select(x =>
                    new AccountBalanceEntry()
                    {
                        AccountNo = x.AccountNo,
                        AccountName = x.AccountName,
                        Amount = x.Amount,
                        Level = x.Level
                    }
                    ).ToList();

                // Show the list on UI
                View.ShowBalanceSheet(sheet);
            }
        }

        private static void BalanceSheetCheck(FinPlannerEntities context)
        {
            // Get a balance sheet account
            var accountEx = context.Account.Where(x => x.DocumentID == _balanceSheetDocumentID).FirstOrDefault();

            // Check if the account does not exist
            if (accountEx == null)
            {
                throw new CoreException(_noBalanceSheetAccountFound);
            }

            // Get the last balance record for this balance sheet account
            var balance = context.Balance.Where(x => x.AccountID == accountEx.AccountID).OrderByDescending(x => x.BalanceID).FirstOrDefault();

            // Check if the balance record is not found
            if (balance == null)
            {
                throw new CoreException(_noBalanceSheetRecordsFound);
            }
        }

        private void View_BalanceSheetUpdated(object sender, AccountBalanceEntry e)
        {
            // Check if the Account No exists
            using (var context = new FinPlannerEntities())
            {
                BalanceSheetCheck(context);

                var account = context.Account.SingleOrDefault(
                    x => x.AccountNo == e.AccountNo && x.DocumentID == _balanceSheetDocumentID);

                // If account is not found
                if (account == null)
                {
                    throw new CoreException(_exAccountNoNotFound);
                }

                var month = DateTime.Now.Month;
                var year = DateTime.Now.Year;

                // Look for the exisiting account record this month
                var balance = context.Balance.SingleOrDefault(
                    x => x.AccountID == account.AccountID && 
                    x.PostingDate.Year == year && x.PostingDate.Month == month);

                // Update the existing record
                balance.Amount = e.Amount;

                context.SaveChanges();
            }
        }

        private void View_MonthEndClosingRequested(object sender, EventArgs e)
        {
            // Check if the previous month has been already closed
            using (var context = new FinPlannerEntities())
            {
                // Get a balance sheet account
                var bsAccount = context.Account.Where(x => x.DocumentID == _balanceSheetDocumentID).FirstOrDefault();

                // Check if the account does not exist
                if (bsAccount == null)
                {
                    throw new CoreException(_noBalanceSheetAccountFound);
                }

                // Get a cashflow account
                var csAccount = context.Account.Where(x => x.DocumentID == _cashflowDocumentID).FirstOrDefault();

                // Check if the account does not exist
                if (csAccount == null)
                {
                    throw new CoreException(_noCashflowAccountFound);
                }

                // Get the last balance records for the both accounts
                var bsBalance = context.Balance.Where(x => x.AccountID == bsAccount.AccountID).OrderByDescending(x => x.BalanceID).FirstOrDefault();
                var csBalance = context.Balance.Where(x => x.AccountID == csAccount.AccountID).OrderByDescending(x => x.BalanceID).FirstOrDefault();

                var month = DateTime.Now.Month;
                var year = DateTime.Now.Year;

                // Check if the records are found
                if (bsBalance != null && csBalance != null)
                {
                    // Check if the found record has the same month and date
                    if (bsBalance.PostingDate.Month == month && bsBalance.PostingDate.Year == year &&
                        csBalance.PostingDate.Month == month && csBalance.PostingDate.Year == year)
                    {
                        throw new CoreException(_exMonthAlreadyClosed);
                    }
                }

                // Call the closing procedure
                var previousMonth = DateTime.Now.AddMonths(-1);
                context.uspCloseFinancialMonth(previousMonth);
            }
        }
    }
}
