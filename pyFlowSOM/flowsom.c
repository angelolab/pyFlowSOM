static int c_plus_seven(int a)
{
    return a + 7;
}

void c_square_each(double arr[], unsigned int n)
{
    for (unsigned int i = 0; i < n; i++)
    {
        for (unsigned int j = 0; j < n; j++)
        {
            int offset = i * n + j;
            arr[offset] = arr[offset] * arr[offset];
        }
    }
}
