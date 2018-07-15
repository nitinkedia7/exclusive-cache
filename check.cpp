/*
 * Actual data storing, data movement and LRU policy not implemented
 * For LRU: for every index we can have a 6 bit counter and every set have a LRU register,
   when there is a access to a set of an index the counter value of the index is incremented
   and copied to the LRU register of the set. At the time of replacement, cache block with smallest LRU value of the index get replaced.
 * */
#include <iostream>
#include <cassert>
#include <cstdlib>
#include <ctime>

#define HIT 1
#define MISS 0

using namespace std;

class Cache {
private:
int set, asso, LS;
int hit_counter,miss_counter;
int **TAG;
int **LRU;
int **TAG_VALID;
int* MRU;
public:
int get_hit(void){
        return hit_counter;
}
int get_miss(void){
        return miss_counter;
}
Cache(){
}            /* Constructor */
void CacheInit( int sets, int associativity, int LineSize ) {
        int i, j;
        TAG = new int*[sets];
        LRU = new int*[sets];
        TAG_VALID = new int*[sets];
        for(i = 0; i < sets; i++) {
                TAG[i] = new int [associativity];
        }
        for(i = 0; i < sets; i++) {
                LRU[i] = new int [associativity];
        }
        for(i = 0; i < sets; i++) {
                TAG_VALID[i] = new int [associativity];
        }
        MRU = new int[sets];
        assert( TAG != NULL );
        /* Initialize tag to be -1 */
        for(i=0; i<sets; i++)
                for(j=0; j<associativity; j++) {
                        TAG[i][j]=0;
                        LRU[i][j]=0;
                        TAG_VALID[i][j]=0;
                        MRU[i]=0;
                }
        /*cout << TAG[5][3] << endl;*/
        asso = associativity; set = sets; LS = LineSize;
        hit_counter=miss_counter=0;
}

~Cache(void){
        delete[] TAG; delete[] TAG_VALID; delete[] LRU; delete MRU;
}                                                                            /* Destructor */

int Access(unsigned int Address, int mode, unsigned int *carry, int *isValid) {
        int i, x;
        int offset = Address % LS;
        int index = (Address/LS) % set;
        int Tag = (Address/LS)/set;
        /*if hit*/
        for(i = 0; i < asso; i++)
                if( TAG[index][i] == Tag && TAG_VALID[index][i] == 1) {
                        hit_counter++;
                        if (mode == 1) {
                            *carry = TAG[index][i];
                            *isValid = TAG_VALID[index][i];
                        }
                        else {
                            TAG_VALID[index][i] = *isValid;
                            TAG[index][i] = (*carry)/4;
                        }
                        LRU[index][i] = ++MRU[index];
                        return HIT;
                }
        miss_counter++;
        /*miss*/
        /* implementing LRU */
        int l = 0;
        int lru_value = LRU[index][0];
        for (int i = 0; i < asso; i++) {
                if (LRU[index][i] < lru_value) {
                        l = i;
                        lru_value = LRU[index][i];
                }
        }
        //x = rand() % asso; /*used random policy for replacement, You have to use LRU policy*/
        if (mode == 1) {
                *carry = TAG[index][l];
                *isValid = TAG_VALID[index][l];
                TAG[index][l] = Tag;
                TAG_VALID[index][l] = 1;
        }
        else {
                TAG[index][l] = (*carry)/4;
                TAG_VALID[index][l] = *isValid;
        }
        LRU[index][l] = ++MRU[index];
        return MISS;
}
};


int main()
{
        int hit;
        unsigned int Address;

        Cache L1;
        Cache L2;
        L1.CacheInit(32, 4, 16);
        L2.CacheInit(128, 8, 16);
        for(int i = 0; i < 1024; i++) {
                //cout << Address << endl;
                unsigned int carry = 0;
                int isValid = 0;
                cin >> Address;
                hit = L1.Access(Address, 1, &carry, &isValid);
                // if (hit == 1 && i == 1023) cout << "L1 query " << Address << " is a HIT.\n";
                if(!hit) {
                        // if (i == 1023) cout << "L1 query " << Address << " is a MISS.\n";
                        hit = L2.Access(Address, 2, &carry, &isValid);
                        // if (i == 1023 && !hit) cout << "L2 query " << Address << " is a MISS.\n";
                        // else if (i == 1023) cout << "L2 query " << Address << " is a MISS.\n";
                }
        }/*end for loop*/
        cout<<"L1: hit "<<L1.get_hit()<<" miss "<<L1.get_miss() << endl;
        cout<<"L2: hit "<<L2.get_hit()<<" miss "<<L2.get_miss() << endl;
        return 0;
}
