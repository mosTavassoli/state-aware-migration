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
  unsigned int i = 0;
  unsigned int counter = 0;
  int get_s = 0;
  int get_l = 0;
  KV get_kv;
  std::string cmd = defineCmd(-1);

  int leader_idx = -2; // index of the replica acting as leader
  // bool reqToLeader = false;         // make request directly to the leader

  std::ofstream outfile;
  std::ostringstream filename;
  // filename << "/app/logs/throughput_put_"+std::to_string(num_keys)+"rep.csv";
  // Write data to file, the file is located inside the container
  filename << "/app/logs/throughput_get_50rep.csv";

  leader_idx = findLeader();

  cmd = defineCmd(leader_idx);
  auto start = std::chrono::high_resolution_clock::now();

  sleep(15);
  while (true)
  {
    auto start_time = std::chrono::high_resolution_clock::now();
    auto end_time = start_time;
    try
    {
      while (std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time).count() < 500)
      {
        get_kv = etcdGet(cmd, "key");
        counter++;
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
  outfile << "id,get_l,get_s\n";
  for (i = 0; i < results.size(); i++)
  {
    outfile << results[i] << std::endl;
  }
  outfile.close();
  // check if the application is finished
  std::cout << "cons-done" << std::endl;

  return 0;
}
