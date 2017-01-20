import java.util.concurrent.atomic.AtomicInteger;

class BetterSorryState implements State{
    private AtomicInteger[] value;
    private byte maxval;

    BetterSorryState(byte[] v) {
        value = new AtomicInteger[v.length];       
        for (int i = 0; i < v.length; i++){
            value[i] = new AtomicInteger(v[i]);
        } 
        maxval = 127;
    }

    BetterSorryState(byte[] v, byte m) {
        value = new AtomicInteger[v.length];       
        for (int i = 0; i < v.length; i++){
            value[i] = new AtomicInteger(v[i]);
        } 
        maxval = 127;
        maxval = m;
    }

    public int size() { return value.length; }

    public byte[] current() { 
        byte[] tmp = new byte[value.length];
        for (int i = 0; i < value.length; i++){
            tmp[i] = (byte) value[i].get();
        }    
        return tmp;     
    }

    public boolean swap(int i, int j) {
        if (value[i].get() <= 0 || value[j].get() >= maxval) {
            return false;
        }
        value[i].getAndDecrement();
        value[j].getAndIncrement();
        return true;
    }
}