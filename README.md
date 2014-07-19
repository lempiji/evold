evold
===========

The evolutionary computation for the D Programming Language.

```D
// The particle swarm optimization sample.
import evold.pso;

void main() {
    auto solver = new MySolver(100);
    solver.initialize();

    foreach (_; 0 .. 100) solver.calculateStep();

    // Results
    auto result = solver.currentBest;
    auto value = solver.currentBestValue;
}

class MySolver : PSOSolver
{
public:
    this(T...)(T args)
    {
        super(args);
    }

protected:
    override double[] makeNewParticle()
    {
        import std.random;
        auto result = new double[3];
        foreach (ref v; result) v = uniform(-1.0, 1.0);
        return result;
    }

    override double calcValue(in double[] x)
    {
        import std.math;
        double result = 0.0;
        foreach (v; x)
        {
            result += v + sin(2 * v) - cos(3 * v);
        }
        return result;
    }
}
```