
public class OrderScheduler {
    private double ordersPerDay;
    private double distMax;
    private double distMin;
    private double distMode;
    private String tractName;
    
    //schedules orders for one census tract
    public OrderScheduler(double ordersPerDay, double distMin, double distMax, double distMode, String tractName) {
        this.ordersPerDay = ordersPerDay;
        this.distMin = distMin;
        this.distMax = distMax;
        this.distMode = distMode;
        this.tractName = tractName;
    }

    //generate order time
    double generateOrderTime(Rand stream) {
        return Simulator.exponential(stream, (24*60)/ordersPerDay);
    }

    //generate distance
    public double generateOrderDistance(Rand stream) {
        //return Simulator.uniform(stream, distMin, distMax);
        return Simulator.triangular(stream, distMin, distMode, distMax);
    }

    public String getTractName() {
        return this.tractName;
    }

	

}
