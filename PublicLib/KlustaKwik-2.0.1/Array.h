// template <class T> class Array;

template <class T>
class Array {
public:
	Array(const T a[], int n) {
		if (n<1) {
			cerr << "Illegal Array m_Size " << n << "\n";
			abort();
		}
		m_Size = n;
		m_Data = new T[m_Size];
			if (!m_Data) {
			cerr << "Could not allocate memory for array of size "
				 << n << "\n";
			abort();
		}
		for (int i=0; i<m_Size; i++) m_Data[i] = a[i];
	}
	Array() { // default constructor, makes an empty array
        m_Data = 0;
        m_Size = 0;
    };
	void SetSize(int n) {
		if (m_Data != 0) delete[] m_Data; // delete old data if there is any
		if (n<1) {
			cerr << "Illegal Array m_Size " << n << "\n";
			abort();
		}
		m_Size = n;
		m_Data = new T[m_Size];
		if (!m_Data) {
			cerr << "Could not allocate memory for array of size "
				 << n << "\n";
			abort();
		}
	}
	Array(int n) {
		if (n<1) {
			cerr << "Illegal Array m_Size " << n << "\n";
			abort();
		}
		m_Size = n;
		m_Data = new T[m_Size];
		if (!m_Data) {
			cerr << "Could not allocate memory for array of size "
				 << n << "\n";
			abort();
		}
	}
	~Array() {
		delete []m_Data;
	}
	int size() const {
		return m_Size;
	}
	T& operator[](int i) const {
		if (i<0 || i>=m_Size) {
			cerr << "Array index " << i << " out of bounds!\n";
			abort();
		}
		return (m_Data[i]);
	}

	Array<T>& operator=(const Array<T> &a) {
		if (m_Size != a.m_Size) {
			cerr << "Copying arrays of different sizes " << m_Size << " and " << a.m_Size << ".\n";
			abort();
		}

		for (int i=0; i<m_Size; i++) {
			m_Data[i] = a.m_Data[i];
		}

		return (*this);
	}

//private:
	T *m_Data;
	int m_Size;
};

template <class T>
class Array2 {
public:
	Array2(int n1, int n2) {
		if (n1<1 || n2<1) {
			cerr << "Illegal 2D Array m_Size " << n1 << "x" << n2 << "\n";
			abort();
		}
		m_Size1 = n1;
		m_Size2 = n2;
		m_Data2 = new Array<T> *[n1];
		if (!m_Data2) {
			cerr << "Could not allocate memory for 2D array of size "
				 << n1 << "x" << n2 << "\n";
			abort();
		}
		for(int i=0; i<n1; i++) {
			m_Data2[i] = new Array<T>(n2);
				if (!m_Data2[i]) {
					cerr << "Could not allocate memory for 2D array of size "
						 << n1 << "x" << n2 << "\n";
				abort();
			}
		}
	}
	~Array2() {
		for(int i=0; i<m_Size1; i++) {
			delete (m_Data2[i]);
		}
		delete[] m_Data2;
	}
	int size1() const {
		return m_Size1;
	}
	int size2() const {
		return m_Size2;
	}
	Array<T>& operator[](int i) const {
		if (i<0 || i>=m_Size1) {
			cerr << "2D Array index " << i << " out of bounds!\n";
			abort();
		}
		return (*(m_Data2[i]));
	}
private:
	Array<T> **m_Data2;
	int m_Size1, m_Size2;
};
