//model drone battery
public class Battery {
	private int dischargeC;
	private int chargeC;
	private int Ah;
	private int inefficiency;
	
	public Battery() {
		this.setDischargeC(15);
		this.setChargeC(1);
		this.setAh(22);
		this.setInefficiency(20);

	}

	public int getDischargeC() {
		return dischargeC;
	}

	public void setDischargeC(int dischargeC) {
		this.dischargeC = dischargeC;
	}

	public int getChargeC() {
		return chargeC;
	}

	public void setChargeC(int chargeC) {
		this.chargeC = chargeC;
	}

	public int getAh() {
		return Ah;
	}

	public void setAh(int ah) {
		Ah = ah;
	}

	public int getInefficiency() {
		return inefficiency;
	}

	public void setInefficiency(int inefficiency) {
		this.inefficiency = inefficiency;
	}

}
