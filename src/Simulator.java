import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
//import umontreal.ssj.probdist.*;
import java.util.HashMap;
import java.util.concurrent.Future;

public class Simulator {
	public Simulator() {
		//
	}

	public int numDrones;
	public int numChargers;
	public int day;
	public double Clock;
	public EventList FutureEventList;
	public Rand stream;
	public static int orderArrival = 1, depart = 2, trip = 3, droneCharged = 4, arriveAtDestination = 5, needland = 6,
			nodeAarrival = 101, nodeBarrival = 102, nodeCarrival = 103, nodeDarrival = 104, nodeEarrival = 105,
			nodeFarrival = 106, nodeGarrival = 107, nodeHarrival = 108, nodeIarrival = 109, nodeJarrival = 110,
			nodeKarrival = 111, nodeLarrival = 112, nodeMarrival = 113, nodeNarrival = 114, nodeOarrival = 115;
	Hub hub = new Hub();
	public int maxOrderID = 0;
	public int numOrders;
	public double totalTime;
	Battery battery = new Battery();

	public HashMap<String, OrderScheduler> demandNodes;

	public void Initialization() {
		numOrders = 0;
		totalTime = 0;
		
		Clock = 480;
		// put drones in the queue

		hub.setChargingCapacity(numChargers);
		for (int i = 0; i < numDrones; i++) {
			Drone drone = new Drone(10, 10, hub); // set the x and y
			hub.addDrone(drone);
		}
		multiNodeInit();

	}

	public void ProcessNodeOrder(String tractName) throws Exception {
		// a drone has just arrived
		//check that drone arrival falls between 8am and 8pm
		if (Clock % 1440 > 480 && Clock % 1440 < 1200) {
			usingFileWriter(Integer.toString(hub.getOrderQueueLength()), "OutputFiles/OrderQueueLength.txt", Clock,
					tractName, (Clock % 1440) / 60); // update info
			Double distance = demandNodes.get(tractName).generateOrderDistance(stream);
			Order order = new Order(distance);// create the order object
			order.setTract(tractName);
			order.setTimePlaced(Clock);
			// are there any orders in the queue
			if (hub.orderAvailable()) {
				hub.addOrder(order);
			}
			// There were no orders in the queue
			else {
				// where there any drones available
				if (hub.droneAvailable()) {
					hub.addOrder(order);
					hub.load();
					double time = uniform(stream, 2, 6);
					Event departure = new Event(depart, Clock + time);// set the time to a loading time (stochastic)
					departure.setDrone(order.getDrone());
					FutureEventList.enqueue(departure);

				}
				// There were no drones available
				else {
					hub.addOrder(order);
				}
			}
		}
		ScheduleNodeOrder(tractName);// schedules the next order
	}

	public void ProcessNodeOrder(String tractName, Order order, Drone drone) throws Exception {
		if (Clock % 1440 > 480 && Clock % 1440 < 1200) {
			usingFileWriter(Integer.toString(hub.getOrderQueueLength()), "OutputFiles/OrderQueueLength.txt", Clock,
					tractName, (Clock % 1440) / 60);
			// a drone has just arrived
			order.setDrone(drone);
			drone.setOrder(order);
			double time = uniform(stream, 2, 6);
			Event departure = new Event(depart, Clock + time);// set the time to a loading time (stochastic)
			departure.setDrone(order.getDrone());
			FutureEventList.enqueue(departure);
			// ScheduleNodeOrder(tractName);// schedules the next order
		}
	}

	public void departure(Event evt) {
		evt.getDrone().setDepartTime(Clock);
		// scheduling when it returns from the trip
		Drone drone = evt.getDrone();
		double time = drone.travel(drone.getOrder().getDistance());
		Event arrive = new Event(arriveAtDestination, Clock + time);
		arrive.setDrone(drone);
		FutureEventList.enqueue(arrive);

	}

	public void leaveDestination(Event evt) throws IOException {
		usingFileWriter(Integer.toString(numOrders + 1), "OutputFiles/OrderFulfillment.txt", Clock,
				evt.getDrone().getOrder().getTract(), (Clock % 1440) / 60);
		Drone drone = evt.getDrone();
		Double flightTime = Clock - drone.getDepartTime();
		// System.out.println(numOrders + "\t" + flightTime);
		drone.getOrder().setTimeReceived(Clock);
		drone.setBattery(drone.getBattery() - (flightTime / 60) * 60);
		Double TripTime = drone.getOrder().getTimeRecieved() - drone.getOrder().getTimePlaced();
		usingFileWriter(Double.toString(TripTime), "OutputFiles/OrderTime.txt", Clock,
				evt.getDrone().getOrder().getTract(), (Clock % 1440) / 60);
		drone.setDepartTime(Clock);
		numOrders += 1;
		totalTime += TripTime;
		// scheduling when it returns from the trip
		double unload = uniform(stream, 1, 5);
		double time = drone.travel(drone.getOrder().getDistance());
		Event Trip = new Event(needland, Clock + time + unload);
		Trip.setDrone(drone);
		FutureEventList.enqueue(Trip);

	}

	public void processLand(Event evt) throws IOException {
		Drone drone = evt.getDrone();
		if (hub.landingAvailable()) {
			hub.Land(drone);
			double time = uniform(stream, 1, 3);
			Event Trip = new Event(trip, Clock + time);
			Trip.setDrone(drone);
			FutureEventList.enqueue(Trip);
		} else {
			hub.AddtoLandingQueue(drone);
		}
	}

	public void processLand(Drone drone) throws IOException {
		hub.Land(drone);
		double time = uniform(stream, 1, 3);
		Event Trip = new Event(trip, Clock + time);
		Trip.setDrone(drone);
		FutureEventList.enqueue(Trip);

	}

	public void processTrip(Event evt) throws IOException {
		Double flightTime = Clock - evt.getDrone().getDepartTime();
		Drone drone = evt.getDrone();
		evt.getDrone().setBattery(evt.getDrone().getBattery() - (flightTime / 60) * 20);
		hub.removefromLandingPad(drone);
		if (hub.droneNeedLand()) {
			Drone drone2 = hub.getNextDroneLand();
			processLand(drone2);
		}

		// schedule add to charging queue
		// check if there is a charger available
		if (hub.chargerAvailable()) {
			hub.chargeDrone(drone);
			double time = ((battery.getAh() - drone.getBattery()) / battery.getAh() * battery.getChargeC() * 60);

			Event DroneCharged = new Event(droneCharged, Clock + time); // time based on equation
			usingFileWriter(Double.toString(drone.getBattery()), "OutputFiles/BatteryLevel.txt", Clock,
					drone.getOrder().getTract(), (Clock % 1440) / 60);
			DroneCharged.setDrone(drone);
			FutureEventList.enqueue(DroneCharged);
		} else {
			hub.addDronetoCharge(drone, Clock);
		}
	}

	public void charge(Event evt) throws Exception {
		// charge and when done add to available queue of drones
		Drone drone1 = evt.getDrone();
		double cost = drone1.getBattery() * .078;
		usingFileWriter(Double.toString(cost), "OutputFiles/Cost.txt", Clock, drone1.getOrder().getTract(),
				(Clock % 1440) / 60);
		usingFileWriter(Double.toString(Clock - drone1.getPutinChargerQueue()), "OutputFiles/ChargerQueueLength.txt",
				Clock, drone1.getOrder().getTract(), (Clock % 1440) / 60);
		drone1.setBattery(22);
		hub.removeDroneFromCharger(drone1);
		// check if there are any open orders
		if (hub.orderAvailable()) {
			Order order = hub.removeOrder();
			ProcessNodeOrder(order.getTract(), order, drone1);
		} else {
			hub.addDrone(drone1);
		}

		if (hub.droneWaitingToCharge()) {
			Drone drone = hub.getNextDrone();
			hub.chargeDrone(drone);
			double time = ((battery.getAh() - drone.getBattery()) / battery.getAh() * battery.getChargeC() * 60);

			Event DroneCharged = new Event(droneCharged, Clock + time); // time based on equation
			DroneCharged.setDrone(evt.getDrone());
			FutureEventList.enqueue(DroneCharged);
		}

	}

	public void Statistics() {
		//System.out.println(numDrones);
		//System.out.println(numChargers);
		//System.out.println("Total time people waited: " + totalTime);
		//System.out.println("Total number of orders placed: " + numOrders);
		//System.out.println("Average time people waited: " + totalTime / numOrders);
		//System.out.println();
	}

	// Distributions
	public static double exponential(Rand rng, double mean) {
		return -mean * Math.log(rng.next());
	}

	public static double uniform(Rand rng, double a, double b) {
		double R = rng.next();
		return (a + (b - a) * R);
	}

	public static double triangular(Rand rng, double a, double m, double b) {
		double R = rng.next();
		if (R < (m - a) / (b - a)) {
			return a + Math.sqrt((b - a) * (m - a) * R);
		} else {
			return b - Math.sqrt((b - a) * (b - m) * (1 - R));
		}
	}

	public void usingFileWriter(String towrite, String File, double time, String tractName, double clockTime)
			throws IOException {

		File file = new File(File);
		FileWriter fr = new FileWriter(file, true);
		BufferedWriter br = new BufferedWriter(fr);
		PrintWriter pr = new PrintWriter(br);
		pr.print(time + "\t" + numDrones + "\t" + numChargers + "\t" + tractName);
		pr.println("\t" + towrite + "\t" + clockTime + "\t" + day);

		pr.close();
		br.close();
		fr.close();

	}

	// set of nodes that are generating orders independently
	// each node is a census tract
	// use orderSchedulerClass - each node gets one order scheduler

	public void multiNodeInit() {
		// create the census tracts
		double percent = .33;
		OrderScheduler nodeA = new OrderScheduler(percent * 96, 0.25, 1.5, 0.65, "A");
		OrderScheduler nodeB = new OrderScheduler(percent * 128, 0.25, 1.5, 0.84, "B");
		OrderScheduler nodeC = new OrderScheduler(percent * 204, 1.35, 3.3, 2.12, "C");
		OrderScheduler nodeD = new OrderScheduler(percent * 152, 0.5, 1.55, 0.94, "D");
		OrderScheduler nodeE = new OrderScheduler(percent * 262, 0.25, 1.7, 0.73, "E");
		OrderScheduler nodeF = new OrderScheduler(percent * 325, 0.25, 4.5, 2.47, "F");
		OrderScheduler nodeG = new OrderScheduler(percent * 213, 0.8, 1.8, 1.12, "G");
		OrderScheduler nodeH = new OrderScheduler(percent * 177, 1.35, 2.25, 1.77, "H");
		OrderScheduler nodeI = new OrderScheduler(percent * 179, 1.25, 2.8, 2.06, "I");
		OrderScheduler nodeJ = new OrderScheduler(percent * 201, 1.6, 3.45, 2.58, "J");
		OrderScheduler nodeK = new OrderScheduler(percent * 118, 2.5, 3.35, 3.04, "K");
		OrderScheduler nodeL = new OrderScheduler(percent * 270, 3.15, 5.35, 4.12, "L");
		OrderScheduler nodeM = new OrderScheduler(percent * 208, 3.5, 5.4, 4.12, "M");
		OrderScheduler nodeN = new OrderScheduler(percent * 357, 3.35, 5, 3.85, "N");
		OrderScheduler nodeO = new OrderScheduler(percent * 235, 1.25, 2.7, 2.23, "O");

		this.demandNodes = new HashMap<>();
		demandNodes.put(nodeA.getTractName(), nodeA);
		demandNodes.put(nodeB.getTractName(), nodeB);
		demandNodes.put(nodeC.getTractName(), nodeC);
		demandNodes.put(nodeD.getTractName(), nodeD);
		demandNodes.put(nodeE.getTractName(), nodeE);
		demandNodes.put(nodeF.getTractName(), nodeF);
		demandNodes.put(nodeG.getTractName(), nodeG);
		demandNodes.put(nodeH.getTractName(), nodeH);
		demandNodes.put(nodeI.getTractName(), nodeI);
		demandNodes.put(nodeJ.getTractName(), nodeJ);
		demandNodes.put(nodeK.getTractName(), nodeK);
		demandNodes.put(nodeL.getTractName(), nodeL);
		demandNodes.put(nodeM.getTractName(), nodeM);
		demandNodes.put(nodeN.getTractName(), nodeN);
		demandNodes.put(nodeO.getTractName(), nodeO);

		// create first orders
		double timeA = demandNodes.get("A").generateOrderTime(stream);
		Event arrivalA = new Event(nodeAarrival, Clock + timeA);
		FutureEventList.enqueue(arrivalA);

		double timeB = demandNodes.get("B").generateOrderTime(stream);
		Event arrivalB = new Event(nodeBarrival, Clock + timeB);
		FutureEventList.enqueue(arrivalB);

		double timeC = demandNodes.get("C").generateOrderTime(stream);
		Event arrivalC = new Event(nodeCarrival, Clock + timeC);
		FutureEventList.enqueue(arrivalC);

		double timeD = demandNodes.get("D").generateOrderTime(stream);
		Event arrivalD = new Event(nodeDarrival, Clock + timeD);
		FutureEventList.enqueue(arrivalD);

		double timeE = demandNodes.get("E").generateOrderTime(stream);
		Event arrivalE = new Event(nodeEarrival, Clock + timeE);
		FutureEventList.enqueue(arrivalE);

		double timeF = demandNodes.get("F").generateOrderTime(stream);
		Event arrivalF = new Event(nodeFarrival, Clock + timeF);
		FutureEventList.enqueue(arrivalF);

		double timeG = demandNodes.get("G").generateOrderTime(stream);
		Event arrivalG = new Event(nodeGarrival, Clock + timeG);
		FutureEventList.enqueue(arrivalG);

		double timeH = demandNodes.get("H").generateOrderTime(stream);
		Event arrivalH = new Event(nodeHarrival, Clock + timeH);
		FutureEventList.enqueue(arrivalH);

		double timeI = demandNodes.get("I").generateOrderTime(stream);
		Event arrivalI = new Event(nodeIarrival, Clock + timeI);
		FutureEventList.enqueue(arrivalI);

		double timeJ = demandNodes.get("J").generateOrderTime(stream);
		Event arrivalJ = new Event(nodeJarrival, Clock + timeJ);
		FutureEventList.enqueue(arrivalJ);

		double timeK = demandNodes.get("K").generateOrderTime(stream);
		Event arrivalK = new Event(nodeKarrival, Clock + timeK);
		FutureEventList.enqueue(arrivalK);

		double timeL = demandNodes.get("L").generateOrderTime(stream);
		Event arrivalL = new Event(nodeLarrival, Clock + timeL);
		FutureEventList.enqueue(arrivalL);

		double timeM = demandNodes.get("M").generateOrderTime(stream);
		Event arrivalM = new Event(nodeMarrival, Clock + timeM);
		FutureEventList.enqueue(arrivalM);

		double timeN = demandNodes.get("N").generateOrderTime(stream);
		Event arrivalN = new Event(nodeNarrival, Clock + timeN);
		FutureEventList.enqueue(arrivalN);

		double timeO = demandNodes.get("O").generateOrderTime(stream);
		Event arrivalO = new Event(nodeOarrival, Clock + timeO);
		FutureEventList.enqueue(arrivalO);
	}

	public void ScheduleNodeOrder(String tractName) {
		double time = demandNodes.get(tractName).generateOrderTime(stream);
		time = Clock + time;
		if (tractName.equals("A"))
			FutureEventList.enqueue(new Event(nodeAarrival, time));
		if (tractName.equals("B"))
			FutureEventList.enqueue(new Event(nodeBarrival, time));
		if (tractName.equals("C"))
			FutureEventList.enqueue(new Event(nodeCarrival, time));
		if (tractName.equals("D"))
			FutureEventList.enqueue(new Event(nodeDarrival, time));
		if (tractName.equals("E"))
			FutureEventList.enqueue(new Event(nodeEarrival, time));
		if (tractName.equals("F"))
			FutureEventList.enqueue(new Event(nodeFarrival, time));
		if (tractName.equals("G"))
			FutureEventList.enqueue(new Event(nodeGarrival, time));
		if (tractName.equals("H"))
			FutureEventList.enqueue(new Event(nodeHarrival, time));
		if (tractName.equals("I"))
			FutureEventList.enqueue(new Event(nodeIarrival, time));
		if (tractName.equals("J"))
			FutureEventList.enqueue(new Event(nodeJarrival, time));
		if (tractName.equals("K"))
			FutureEventList.enqueue(new Event(nodeKarrival, time));
		if (tractName.equals("L"))
			FutureEventList.enqueue(new Event(nodeLarrival, time));
		if (tractName.equals("M"))
			FutureEventList.enqueue(new Event(nodeMarrival, time));
		if (tractName.equals("N"))
			FutureEventList.enqueue(new Event(nodeNarrival, time));
		if (tractName.equals("O"))
			FutureEventList.enqueue(new Event(nodeOarrival, time));
		//
	}

}
