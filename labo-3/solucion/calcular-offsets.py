# Definición de tamaños y alineaciones para una arquitectura x86_64
size_ptr = 8         # Tamaño de un puntero (next y arreglo)
size_uint8 = 1       # Tamaño de un uint8_t (categoria)
size_uint32 = 4      # Tamaño de un uint32_t (longitud)

# Calculo de tamaños y offsets para nodo_t
# Alineación natural para estructuras sin el atributo packed
alignment_nodo_t = size_ptr  # La alineación de la estructura es la del miembro de mayor alineación

# Calculamos el offset y tamaño de manera que respete la alineación
offset_longitud_nodo_t = size_ptr + (size_uint8 + (size_ptr - (size_uint8 % size_ptr) % size_ptr)) + size_ptr
nodo_length = offset_longitud_nodo_t + size_uint32
nodo_length = (nodo_length + (alignment_nodo_t - 1)) & ~(alignment_nodo_t - 1)  # slineacion del tamaño total

# calculo de tamaños y offsets para packed_nodo_t
# en una estructura packed, los miembros están alineados a 1, así que no hay padding entre ellos
offset_longitud_packed_nodo_t = size_ptr + size_uint8 + size_ptr
packed_nodo_length = offset_longitud_packed_nodo_t + size_uint32

print(nodo_length, offset_longitud_nodo_t, packed_nodo_length, offset_longitud_packed_nodo_t)
