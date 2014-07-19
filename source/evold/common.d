module evold.common;

interface IEvolutionalySolver
{
public:
	const(double[]) currentBest() const @property;
	double currentBestValue() const @property;

public:
	void initialize();
	void calculateStep();
}
