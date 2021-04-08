

public class Order {
    private static int maxOrderId = 0;
    private int orderId;
    private Destination destination;
    private Drone drone;
    private double timePlaced;
    private double timeReceived;
    private double distance;
    private String tract;

    public Order(double distance) {
        maxOrderId += 1;
        orderId = maxOrderId;
        this.distance = distance;
    }


    //getters and setters

    public int getOrderId () {
        return this.orderId;
    }

    public void setOrderId (int orderId) {
        this.orderId = orderId;
    }
    
    public Destination getDestination () {
        return this.destination;
    }

    public void setDestination (Destination destination) {
        this.destination = destination;
    }
    public void setDrone(Drone drone) {
    	this.drone = drone;
    }
    
    public Drone getDrone() {
    	return this.drone;
    }
    
    public void setTimePlaced(Double time) {
    	timePlaced = time;
    }
    
    public Double getTimePlaced() {
    	return timePlaced;
    }
    
    public void setTimeReceived(Double time) {
    	timeReceived = time;
    }
    
    public Double getTimeRecieved() {
    	return timeReceived;
    }

    public double getDistance() {
        return distance;
    }

    public void setDistance(double distance) {
        this.distance = distance;
    }
    
    public void setTract(String tract) {
    	this.tract = tract;
    }
    public String getTract() {
    	return this.tract;
    }
}
