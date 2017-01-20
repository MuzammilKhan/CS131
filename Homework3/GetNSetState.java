import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State{
    private AtomicIntegerArray value;
    private byte maxval;

    GetNSetState(byte[] v) {
       int[] tmp = new int[v.length];
        for (int i = 0; i < v.length; i++){
            tmp[i] = (int) v[i];
        } 
        value = new AtomicIntegerArray (tmp);
        maxval = 127;
    }

    GetNSetState(byte[] v, byte m) {
        int[] tmp = new int[v.length];
        for (int i = 0; i < v.length; i++){
            tmp[i] = v[i];
        } 
        value = new AtomicIntegerArray (tmp);
        maxval = m;
    }

    public int size() { return value.length(); }

    public byte[] current() { 
        byte[] tmp = new byte[value.length()];
        for (int i = 0; i < value.length(); i++){
            tmp[i] = (byte) value.get(i);
        }    
        return tmp;     
    }

    public boolean swap(int i, int j) {
    int valuei = value.get(i);
    int valuej = value.get(j);
    if (valuei <= 0 || valuej >= maxval) {
        return false;
    }
    value.set(i, valuei-1);
    value.set(j, valuej+1);
    return true;
    }

}