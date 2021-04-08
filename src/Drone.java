import java.lang.Math; 

public class Drone {
    private int droneId;
    private static int maxDroneId = 0;
    private Order order;
    private double battery = 22;
    private int xPos;
    private int yPos;
    private int xDest;
    private int yDest;
    private double speed = 38; //
    private Hub hub;
    private double departTime;
    private double PutinChargerQueue = 0;

    public Drone(int x, int y, Hub hub) {
        maxDroneId += 1;
        droneId = maxDroneId;
        xPos = x;
        yPos = y;
        this.hub = hub;
    }

    //returns travel time
    public double travel(int xTarget, int yTarget) {
        double distance = Math.sqrt((xTarget - this.xPos)*(xTarget - this.xPos) + (yTarget - this.yPos)*(yTarget - this.yPos));
        return travel(distance);
    }

    //calculate travel time based on distance
    public double travel(double distance) {
        return (distance/this.speed)*60;
    }

    //unload delivery
    public void unload() {
        this.order = null;
    }

    //getters and setters

    public int getDroneId() {
        return this.droneId;
    }

    public void setDroneId(int droneId) {
        this.droneId = droneId;
    }

    public int getxPos() {
        return this.xPos;
    }

    public void setxPos(int xPos) {
        this.xPos = xPos;
    }

    public int getyPos() {
        return this.yPos;
    }

    public void setyPos(int yPos) {
        this.yPos = yPos;
    }

    public double getBattery() {
        return this.battery;
    }

    public void setBattery(double battery) {
        this.battery = battery;
    }

    public Order getOrder() {
        return this.order;
    }

    public void setOrder(Order order) {
        this.order = order;
    }

    public int getXDest (){
        return this.xDest;
    }

    public void setXDest(int x) {
        this.xDest = x;
    }
    
    public int getYDest (){
        return this.yDest;
    }

    public void setYDest(int y) {
        this.yDest = y;
    }
    
    public void setDepartTime(double time) {
    	this.departTime = time;
    }
    
    public double getDepartTime() {
    	return(this.departTime);
    }

	public double getPutinChargerQueue() {
		return PutinChargerQueue;
	}

	public void setPutinChargerQueue(double putOnChargerTime) {
		this.PutinChargerQueue = putOnChargerTime;
	}
}