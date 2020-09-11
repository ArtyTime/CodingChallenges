using System;
using System.Collections.Generic;
 
namespace CodingChallenge
{
    class Program
    {
        static void Main(string[] args)
        {
            var outputLines = new List<string>();

            string input;

            while (!string.IsNullOrEmpty(input = Console.ReadLine()))
                foreach (var character in input)
                {
                    var charsInLine = 0;

                    for (var i = 0; i < input.Length; i++)
                        if (input[i] == character)
                            charsInLine++;

                    if (charsInLine == 2 && !outputLines.Contains(input))
                        outputLines.Add(input);
                }

            foreach (var outputLine in outputLines)
                Console.WriteLine(outputLine);
        }
    }
}