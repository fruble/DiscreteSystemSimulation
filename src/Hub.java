import java.util.Queue;
import java.util.LinkedList;
import java.util.ArrayList;

//Drone hub at walmart store
//Tracks 
public class Hub {
	private Queue<Order> orderQueue = new LinkedList<>();
	private Queue<Drone> availableDroneQueue = new LinkedList<>();
	private Queue<Drone> chargingDronesQueue = new LinkedList<>();
	private Queue<Drone> landingDronesQueue = new LinkedList<>();
	private Drone[] landingPads = new Drone[5];

	private int chargingCapacity;
	private Drone[] chargers;

	public Hub() {
		//
	}

	public boolean landingAvailable() {
		for (int i = 0; i < 5; i++) {
			if (landingPads[i] == null) {
				return true;
			}
		}
		return false;
	}

	public void Land(Drone drone) {
		for (int i = 0; i < 5; i++) {
			if (landingPads[i] == null) {
				landingPads[i] = drone;
				break;
			}
		}
	}
	
	public void removefromLandingQueue() {
		landingDronesQueue.remove();
	}
	
	public void removefromLandingPad(Drone drone) {
		for (int i = 0; i < 5; i++) {
			if (landingPads[i] == drone) {
				landingPads[i] = null;
				break;
			}
		}
	}
	
	public boolean droneNeedLand() {
		return !landingDronesQueue.isEmpty();
	}
	
	public void AddtoLandingQueue(Drone drone) {
		landingDronesQueue.add(drone);
	}
	
	public Drone getNextDroneLand() {
		Drone drone = landingDronesQueue.remove();
		return drone;
	}

	// check if there is an available drone
	public boolean droneAvailable() {
		return !availableDroneQueue.isEmpty();
	}

	// check if there is an order
	public boolean orderAvailable() {
		return !orderQueue.isEmpty();
	}

	// check if there is a drone waiting to be charged
	public boolean droneWaitingToCharge() {
		return !chargingDronesQueue.isEmpty();
	}

	// check if there is a charger available
	public boolean chargerAvailable() {
		for (int i = 0; i < chargingCapacity; i++) {
			if (chargers[i] == null) {
				return true;

			}
		}
		return false;
	}

	// remove an order from the order queue, a drone from the drone queue, assign
	// order to drone
	public Drone load() throws Exception {
		if (orderAvailable() && droneAvailable()) {
			Order nextOrder = orderQueue.remove();
			Drone nextDrone = availableDroneQueue.remove();
			nextOrder.setDrone(nextDrone);
			nextDrone.setOrder(nextOrder);
			return nextDrone;
		} else {
			throw new Exception("order and/or drone not available");
		}
	}

	public void addDrone(Drone drone) {
		this.availableDroneQueue.add(drone);
	}

	public void addOrder(Order order) {
		this.orderQueue.add(order);
	}

	public Order removeOrder() {
		return this.orderQueue.remove();
	}

	public void addDronetoCharge(Drone drone, double Clock) {
		drone.setPutinChargerQueue(Clock);
		this.chargingDronesQueue.add(drone);
	}

	// put drone on charger
	public void chargeDrone(Drone drone) {

		for (int i = 0; i < chargingCapacity; i++) {
			if (chargers[i] == null) {
				chargers[i] = drone;
				break;
			}
		}
	}

	// remove drone from charger
	public void removeDroneFromCharger(Drone drone) {
		for (int i = 0; i < chargingCapacity; i++) {
			if (chargers[i] == drone) {
				chargers[i] = null;
			}
		}
	}

	// get the next drone from the list to charge
	public Drone getNextDrone() {
		Drone drone = chargingDronesQueue.remove();
		return drone;
	}

	public int getChargingCapacity() {
		return this.chargingCapacity;
	}

	public void setChargingCapacity(int huchargingCapacitybY) {
		chargers = new Drone[huchargingCapacitybY];
		this.chargingCapacity = huchargingCapacitybY;
	}

	public int getOrderQueueLength() {
		return orderQueue.size();
	}
}
