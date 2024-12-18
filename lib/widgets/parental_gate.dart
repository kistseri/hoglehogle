import 'dart:math';

class ParentalGate {
  static Map<String, dynamic> generateComplexMathProblem() {
    final random = Random();
    final problemType = ["arithmetic", "fraction", "equation", "pattern"]
    [random.nextInt(4)];

    String problem;
    dynamic solution;

    switch (problemType) {
      case "arithmetic":
      // Generate a complex arithmetic problem
        final a = random.nextInt(41) + 10; // 10 to 50
        final b = random.nextInt(41) + 10;
        final c = random.nextInt(20) + 1;
        final d = random.nextInt(9) + 2;
        final e = random.nextInt(16) + 5;
        problem = "($a × $b) - ($c × $d) + $e";
        solution = (a * b) - (c * d) + e;
        break;

      case "fraction":
      // Generate a fraction multiplication problem with integer solutions
        final num1 = random.nextInt(10) + 1; // Numerator 1
        final den1 = random.nextInt(9) + 2; // Denominator 1
        final num2 = random.nextInt(10) + 1; // Numerator 2
        final den2 = den1; // Same denominator to ensure integer result
        problem = "($num1/$den1) × ($num2/$den2)";
        solution = (num1 * num2) ~/ (den1); // Integer division ensures whole number
        break;

      case "equation":
      // Generate a simple algebraic equation with integer solution
        final x = random.nextInt(10) + 1; // x value
        final a = random.nextInt(9) + 2; // Coefficient for x
        final b = random.nextInt(20) + 1; // Constant
        final c = (a * x) + b; // Ensure integer result for c
        problem = "$a * x + $b = $c. x의 값은 ?";
        solution = x; // The value of x
        break;


      default:
        final a = random.nextInt(30) + 10; // 10 to 39
        final b = random.nextInt(30) + 10; // 10 to 39
        final c = random.nextInt(20) + 1;  // 1 to 20
        final d = random.nextInt(15) + 5;  // 5 to 19
        problem = "($a + $b) - ($c × $d)";
        solution = (a + b) - (c * d);
        break;
    }

    return {"problem": problem, "solution": solution};
  }
}