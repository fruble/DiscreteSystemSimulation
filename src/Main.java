import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

public class Main {

	public static void main(String argv[]) throws Exception {
		//initialize output files
		usingFileWriter("OrderQueueLength", "OutputFiles/OrderQueueLength.txt");
		usingFileWriter("NumberofOrders", "OutputFiles/OrderFulfillment.txt");
		usingFileWriter("WaitTime", "OutputFiles/OrderTime.txt");
		usingFileWriter("BatteryLevel", "OutputFiles/BatteryLevel.txt");
		usingFileWriter("QueueLength", "OutputFiles/ChargerQueueLength.txt");
		usingFileWriter("Cost", "OutputFiles/ChargerQueueLength.txt");

		for (int i = 20; i <= 30; i++) {
			System.out.println(i);
			for (int j = i / 2; j <= i; j++) {
				Rand stream = new Rand();
				for (int k = 0; k < 10; k++) {
					
					//initialize simulation
					Simulator ss = new Simulator();
					ss.stream = stream;
					ss.FutureEventList = new EventList();
					ss.Clock = 0.0;
					ss.numDrones = i;
					ss.numChargers = j;
					ss.day = k;
					ss.Initialization();
					//while simulation time less than 1440
					while (ss.Clock <= 1440) {
						Event evt = ss.FutureEventList.getMin(); // get imminent event
						ss.FutureEventList.dequeue(); // delete the event
						ss.Clock = evt.get_time(); // advance in time
						//process event depending on event type
						if (evt.get_type() == Simulator.depart)
							ss.departure(evt);
						if (evt.get_type() == Simulator.trip)
							ss.processTrip(evt);
						if (evt.get_type() == Simulator.droneCharged)
							ss.charge(evt);
						if (evt.get_type() == Simulator.arriveAtDestination)
							ss.leaveDestination(evt);
						if (evt.get_type() == Simulator.needland)
							ss.processLand(evt);
						if (evt.get_type() == Simulator.nodeAarrival)
							ss.ProcessNodeOrder("A");
						if (evt.get_type() == Simulator.nodeBarrival)
							ss.ProcessNodeOrder("B");
						if (evt.get_type() == Simulator.nodeCarrival)
							ss.ProcessNodeOrder("C");
						if (evt.get_type() == Simulator.nodeDarrival)
							ss.ProcessNodeOrder("D");
						if (evt.get_type() == Simulator.nodeEarrival)
							ss.ProcessNodeOrder("E");
						if (evt.get_type() == Simulator.nodeFarrival)
							ss.ProcessNodeOrder("F");
						if (evt.get_type() == Simulator.nodeGarrival)
							ss.ProcessNodeOrder("G");
						if (evt.get_type() == Simulator.nodeHarrival)
							ss.ProcessNodeOrder("H");
						if (evt.get_type() == Simulator.nodeIarrival)
							ss.ProcessNodeOrder("I");
						if (evt.get_type() == Simulator.nodeJarrival)
							ss.ProcessNodeOrder("J");
						if (evt.get_type() == Simulator.nodeKarrival)
							ss.ProcessNodeOrder("K");
						if (evt.get_type() == Simulator.nodeLarrival)
							ss.ProcessNodeOrder("L");
						if (evt.get_type() == Simulator.nodeMarrival)
							ss.ProcessNodeOrder("M");
						if (evt.get_type() == Simulator.nodeNarrival)
							ss.ProcessNodeOrder("N");
						if (evt.get_type() == Simulator.nodeOarrival)
							ss.ProcessNodeOrder("O");
					}
					ss.Statistics();
				}

			}
		}

	}

	public static void usingFileWriter(String towrite, String File) throws IOException {
		File file = new File(File);
		FileWriter fr = new FileWriter(file, false);
		BufferedWriter br = new BufferedWriter(fr);
		PrintWriter pr = new PrintWriter(br);
		pr.println("Clock" + "\t" + "NumberofDrones" + "\t" + "NumberofChargers" + "\t" + "tractName" + "\t" + towrite
				+ "\t" + "ClockTime" + "\t" + "day");
		pr.close();
		br.close();
		fr.close();

	}

}
