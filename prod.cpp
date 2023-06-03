#include "etcdAPIs.hpp"
#include <unistd.h> //getpid()
#include <math.h>   //pow()
#include <chrono>   //time measurement
#include <fstream>  //file management
#include <thread>

using namespace std;

/* CRUD: Create, Read, Update, Delete operations test */

int main(int argc, char *argv[])
{
  std::vector<std::string> results; // vector to store results
  unsigned int put_keys = 0;        // number of keys put in etcd
  float key_size_abs = 100;         // number of bytes per key
  int key_size = 0;                 // number of bytes per key normalized in [B]
  // unsigned int max = std::numeric_limits<unsigned int>::max();
  std::string cmd = defineCmd(-1);
  int leader_idx = -2; // index of the replica acting as leader
                       // bool reqToLeader = false;         // make request directly to the leader

  // Circular buffer variables
  float exp = 0; // value passed from cli
  float N = 0;   // buffer size in bytes

  // Assigning values from command line
  exp = atof(argv[1]);          // buffer size exponent as 10^x
  key_size_abs = atof(argv[2]); // number of bytes per key
  // int rep = atof(argv[3])
  //  Initializing random number generator
  srand((unsigned)time(NULL) * getpid());

  // Initializing state size and key size
  N = pow(10, exp);
  key_size = key_size_abs * pow(10, 3); // normalized in [B]

  // Find and change Raft leader
  leader_idx = findLeader();
  cmd = defineCmd(leader_idx);

  // Calculating number of keys
  int num_keys = (int)round(N / (float)key_size);

  // Initializing etcd client
  KV get_kv;
  int counter = 0;
  KV new_kv;
  new_kv.key = "key";

  std::ofstream outfile;
  std::ostringstream filename;
  filename << "throughput_put_" + std::to_string(num_keys) + "rep.csv";

  // Write data to file
  outfile.open(filename.str().c_str(), std::ios::out | std::ios::app);
  if (!outfile.is_open())
  {
    std::cerr << "Unable to open file" << std::endl;
    return 1;
  }
  sleep(15);
  while (true)
  {
    auto start_time = std::chrono::high_resolution_clock::now();
    auto end_time = start_time;
    std::string rand_string = randStr(key_size);
    new_kv.value = rand_string;
    try
    {
      while (std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count() < 500)
      {
        bool res = etcdPut(cmd, new_kv);
        if (res == true)
        {
          counter++;
        }
        end_time = std::chrono::high_resolution_clock::now();
      }
      // std::cout << rand_string;
      std::cout << to_string((unsigned)time(NULL)) + "," + std::to_string(counter) << std::endl;
      results.push_back(std::to_string((unsigned)time(NULL)) + "," + std::to_string(counter));
      counter = 0;
    }
    catch (const std::exception &e)
    {
      // handle etcd client library exceptions
      std::cerr << "Exception caught: " << e.what() << std::endl;
      // sleep for some time before retrying
      std::this_thread::sleep_for(std::chrono::seconds(5));
    }
  }

  outfile << "id,put\n";
  for (const auto &result : results)
  {
    outfile << result << std::endl;
  }

  outfile.close();
  std::cout << "prod-done" << std::endl;
  return 0;
}
