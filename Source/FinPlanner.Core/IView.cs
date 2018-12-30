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

    public interface IView
    {
        // Step 1: Determine Your Personal Net Worth.
        event EventHandler<DateTime> BalanceSheetRequested;
        event EventHandler<AccountBalanceEntry> BalanceSheetUpdated;
        void ShowBalanceSheet(List<AccountBalanceEntry> items);
        event EventHandler MonthEndClosingRequested;
    }
}
