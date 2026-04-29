// Assuming this is the required modification for the method chaining issue.

public static class Extensions
{
    public static void DoSomething(this SomeType obj)
    {
        obj.Method1();
        obj.Method2(); // Previously chained, now separate statements
    }

    public static void AnotherAction(this SomeType obj)
    {
        obj.Method3(); // Previously chained
        obj.Method4(); // Previously chained
    }
}