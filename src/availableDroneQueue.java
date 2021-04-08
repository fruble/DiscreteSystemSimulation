//Queue of drones available to complete deliveries
import java.util.Vector;  
public class availableDroneQueue{
	private Vector<Drone> all_data;
    
	public availableDroneQueue(){
    	all_data = new Vector<Drone>();
    }
    
    public void enqueue(Drone e){
    	all_data.addElement(e);
    }
    
    public Drone dequeue(){
    	Drone res = all_data.elementAt(0);
        all_data.removeElementAt(0);
        return res;
    }
    
    public Drone Get(int i){
    	return all_data.elementAt(i);
    }
    
    public int size() {
    	return all_data.size();
    }
    
    public void remove(int i) {
    	all_data.removeElementAt(0);
    }
}