/**
 *  Configuration file for wiring of FakeSensorP module to other common 
 *  components to simulate the behavior of a real sensor
 *
 *  @author Luca Pietro Borsani
 */
 
generic configuration FakeSensorC() {

	provides interface Read<uint16_t> as TempRead;
	provides interface Read<uint16_t> as HumRead;
	provides interface Read<uint16_t> as LumRead;

} implementation {

	components MainC, RandomC;
	components new FakeSensorP();
	components new TimerMilliC() as ReadTempTimer;
	components new TimerMilliC() as ReadHumTimer;
	components new TimerMilliC() as ReadLumTimer;
	
	//Connects the provided interface
	
	TempRead = FakeSensorP.TempRead;
	HumRead = FakeSensorP.HumRead;
	LumRead = FakeSensorP.LumRead;
	
	
	//Random interface and its initialization	
	FakeSensorP.Random -> RandomC;
	RandomC <- MainC.SoftwareInit;
	
	//Timer interface	
	FakeSensorP.TimerReadTemp -> ReadTempTimer;
	FakeSensorP.TimerReadHum -> ReadHumTimer;
	FakeSensorP.TimerReadLum -> ReadLumTimer;

}
