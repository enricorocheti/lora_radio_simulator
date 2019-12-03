function bit_error = get_bit_error(a,b,sf)
    result = bitxor(a,b);
    bit_error = 0;
    for i = [1:sf]
        if bitget(result,i) == 1
            bit_error = bit_error + 1;
        end
    end
end