def array_to_string(array)
    string = ""
    array.each do |a|
        string += a + ", "
    end
    return string[0...-2]

end