using System;
using System.Collections.Generic;

namespace FinPlanner.Core
{
    public class AccountBalanceEntry
    {
        public string AccountNo { get; set;  }
        public string AccountName { get; set; }
        public DateTime PostingDate { get; set; }
        public double Amount { get; set; }
        public double Budget { get; set; }
        public int Level { get; set; }
    }

    public class GoalEntry
    {
        public int GoalNo { get; set; }
        public string GoalName { get; set; }
        public DateTime Due { get; set; }
        public int GoalID { get; set; }
    }

    public class JournalEntry
    {
        public DateTime PostingDate { get; set; }
        public string AccountNo { get; set; }
        public string AccountName { get; set; }
        public double Amount { get; set; }
        public string Description { get; set; }
    }

    public interface IView
    {
        // Step 1: Determine Your Personal Net Worth.
        event EventHandler<DateTime> BalanceSheetRequested;
        event EventHandler<AccountBalanceEntry> BalanceSheetUpdated;
        void ShowBalanceSheet(List<AccountBalanceEntry> items);

        // Step 2: Set Your Financial Goals.
        event EventHandler GoalListRequested;
        event EventHandler NewGoalsRequested;
        event EventHandler<List<GoalEntry>> NewGoalsSelected;
        void ShowGoalList(List<GoalEntry> items);
        void SuggestGoals(List<GoalEntry> items);

        // Step 3: Keep Simple Records.
        event EventHandler<DateTime> CashflowRequested;
        event EventHandler<DateTime> JournalRequested;
        event EventHandler<JournalEntry> JournalUpdated;
        event EventHandler MonthEndClosingRequested;
        void ShowCashflow(List<AccountBalanceEntry> items);
        void ShowJournal(List<JournalEntry> items);

        // Step 4: Set Your Monthly Budget.
        event EventHandler<AccountBalanceEntry> BudgetUpdated;
    }
}
