//Event object, could be demand arrival, drone departure, drone arrival, drone entering queue to charge, drone completing charging etc.
public class Event{
	private double time ;
    private int type;
    private Drone drone;
    
    public Event ( int _type , double _time){
    	type = _type ;
        time = _time ;
    }

    public double get_time(){
    	return time;
    }
    
    public int get_type (){
    	return type;
    }
    
    public void setDrone(Drone drone) {
    	this.drone = drone;
    }
    
    public Drone getDrone() {
    	return this.drone;
    }
}