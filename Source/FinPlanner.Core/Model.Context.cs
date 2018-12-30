﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace FinPlanner.Core
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
    using System.Linq;
    
    public partial class FinPlannerEntities : DbContext
    {
        public FinPlannerEntities()
            : base("name=FinPlannerEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<Account> Account { get; set; }
        public virtual DbSet<Balance> Balance { get; set; }
        public virtual DbSet<Document> Document { get; set; }
        public virtual DbSet<vBalanceSheet> vBalanceSheet { get; set; }
    
        public virtual int uspCalculateBalanceSheetTotals(Nullable<System.DateTime> monthSelector)
        {
            var monthSelectorParameter = monthSelector.HasValue ?
                new ObjectParameter("monthSelector", monthSelector) :
                new ObjectParameter("monthSelector", typeof(System.DateTime));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("uspCalculateBalanceSheetTotals", monthSelectorParameter);
        }
    
        public virtual int uspCloseFinancialMonth(Nullable<System.DateTime> monthSelector)
        {
            var monthSelectorParameter = monthSelector.HasValue ?
                new ObjectParameter("monthSelector", monthSelector) :
                new ObjectParameter("monthSelector", typeof(System.DateTime));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("uspCloseFinancialMonth", monthSelectorParameter);
        }
    }
}
