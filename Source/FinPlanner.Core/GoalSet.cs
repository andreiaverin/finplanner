
//------------------------------------------------------------------------------
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
    using System.Collections.Generic;
    
public partial class GoalSet
{

    public int GoalSetID { get; set; }

    public int GoalID { get; set; }

    public System.DateTime StartDate { get; set; }

    public System.DateTime EndDate { get; set; }

    public string Description { get; set; }

    public int Order { get; set; }



    public virtual Goal Goal { get; set; }

}

}
