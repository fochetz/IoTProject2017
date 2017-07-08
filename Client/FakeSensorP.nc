/**
 *  Source file for implementation of module Middleware
 *  which provides the main logic for middleware message management
 *
 *  @author Luca Pietro Borsani
 */
#define temperatureMaxBound 40
#define humidityMaxBound 100
#define luminosityMaxBound 1000
generic module FakeSensorP() {

	provides interface Read<uint16_t> as TempRead;
	provides interface Read<uint16_t> as HumRead;
	provides interface Read<uint16_t> as LumRead;
	
	uses interface Random;
	uses interface Timer<TMilli> as TimerReadTemp;
	uses interface Timer<TMilli> as TimerReadHum;
	uses interface Timer<TMilli> as TimerReadLum;

} implementation {

	//***************** Boot interface Temperature********************//
	command error_t TempRead.read(){
		call TimerReadTemp.startOneShot( 1000 );
		return SUCCESS;
	}

	//***************** TimerReadTemp interface ********************//
	event void TimerReadTemp.fired() {
		uint16_t value;
		value = call Random.rand16() %temperatureMaxBound;		
		signal TempRead.readDone( SUCCESS, value );
	}


	//***************** Boot interface Humidity ********************//
	command error_t HumRead.read(){
		call TimerReadHum.startOneShot( 2000 );
		return SUCCESS;
	}

	//***************** TimerReadHum interface ********************//
	event void TimerReadHum.fired() {
		uint16_t value;
		value = call Random.rand16() %humidityMaxBound;		
		signal HumRead.readDone( SUCCESS, value );
	}


	//***************** Boot interface Luminosity ********************//
	command error_t LumRead.read(){
		call TimerReadLum.startOneShot( 4000 );
		return SUCCESS;
	}

	//***************** TimerReadLum interface ********************//
	event void TimerReadLum.fired() {
		uint16_t value;
		value = call Random.rand16() %luminosityMaxBound;		
		signal LumRead.readDone( SUCCESS, value );
	}
}
