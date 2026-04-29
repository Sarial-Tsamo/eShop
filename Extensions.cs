// Fixing method chaining errors on lines 43 and 49

// Removing the chained .AddEmbeddingGenerator() calls

// Previously, it looked like this:
// .AddEmbeddingGenerator().AddSomeOtherFunction()
// Now we call them separately:
.AddEmbeddingGenerator();
.AddSomeOtherFunction();

// Ensure you have proper context here for your implementation
