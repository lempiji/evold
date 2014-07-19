module evold.pso;

public import evold.common;

private import std.algorithm;
private import std.parallelism;
private import std.random;

class PSOSolver : IEvolutionalySolver
{
public:
	this(size_t poolSize, double inertiaRate = 0.98, double c1 = 1.2, double c2 = 1.2)
	{
		_poolSize = poolSize;
		_inertiaRate = inertiaRate;
		_c1 = c1;
		_c2 = c2;
	}

public:
	const(double[]) currentBest() const pure nothrow @safe @property
	{
		return _globalBest.position;
	}
	double currentBestValue() const pure nothrow @safe @property
	{
		return _globalBest.value;
	}

public:
	void initialize()
	{
		_pool = new Particle[_poolSize];
		foreach (ref p; parallel(_pool))
		{
			p = new Particle;
			p.position = makeNewParticle();
			p.localBest = p.position.dup;
			p.velocity = new double[p.position.length];
			p.velocity[] = 0.0;
			p.value = calcValue(p.position);
			p.localBestValue = p.value;
		}

		size_t index = 0;
		double best = double.max;
		foreach (i; 0 .. _pool.length)
		{
			if (_pool[i].value < best)
			{
				best = _pool[i].value;
				index = i;
			}
		}

		_globalBest = new Particle;
		_globalBest.position = _pool[index].position.dup;
		_globalBest.velocity = _pool[index].velocity.dup;
		_globalBest.localBest = _pool[index].localBest.dup;
		_globalBest.localBestValue = _pool[index].localBestValue;
		_globalBest.value = _pool[index].value;
	}

	void calculateStep()
	{
		foreach (p; parallel(_pool))
		{
			immutable r1 = uniform(0.0, 1.0);
			immutable r2 = uniform(0.0, 1.0);
			p.velocity[] = _inertiaRate * p.velocity[]
				+ _c1 * r1 * _globalBest.position[]
				+ _c2 * r2 * p.localBest[]
				- (_c1 * r2 + _c2 * r2) * p.position[];

			p.position[] += p.velocity[];

			p.value = calcValue(p.position);
			if (p.value < p.localBestValue)
			{
				p.localBest[] = p.position[];
				p.localBestValue = p.value;
			}
		}

		size_t index = 0;
		double best = double.max;
		foreach (i; 0 .. _pool.length)
		{
			if (_pool[i].value < best)
			{
				best = _pool[i].value;
				index = i;
			}
		}

		if (best < _globalBest.value)
		{
			_globalBest.position[] = _pool[index].position[];
			_globalBest.velocity[] = _pool[index].velocity[];
			_globalBest.localBest[] = _pool[index].localBest[];
			_globalBest.localBestValue = _pool[index].localBestValue;
			_globalBest.value = _pool[index].value;
		}
	}

protected:
	abstract double[] makeNewParticle();
	abstract double calcValue(in double[] x);

private:
	size_t _poolSize;
	double _inertiaRate;
	double _c1;
	double _c2;

	Particle _globalBest;
	Particle[] _pool;

private:
	class Particle
	{
		double[] position;
		double value;
		double[] localBest;
		double localBestValue;
		double[] velocity;
	}
}
