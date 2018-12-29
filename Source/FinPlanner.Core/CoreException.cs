using System;

namespace FinPlanner.Core
{
    public class CoreException : Exception
    {
        public CoreException(string message) : base(message) { }
    }
}
