import java.util.Vector;  
public class orderQueue{
	private Vector<Order> all_data;
    
	public orderQueue(){
    	all_data = new Vector<Order>();
    }
    
    public void enqueue(Order e){
    	all_data.addElement(e);
    }
    
    public Order dequeue(){
    	Order res = all_data.elementAt(0);
        all_data.removeElementAt(0);
        return res;
    }
    
    public Order Get(int i){
    	return all_data.elementAt(i);
    }
    
    public int size() {
    	return all_data.size();
    }
    
    public void remove(int i) {
    	all_data.removeElementAt(0);
    }
}