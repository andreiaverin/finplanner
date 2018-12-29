namespace FinPlanner.Console
{
    class Program
    {
        static void Main(string[] args)
        {
            // Instantiate the view and the presenter
            var view = new View();
            var presenter = new Core.Presenter(view);

            // Start the user interaction
            view.Show();
        }
    }
}
